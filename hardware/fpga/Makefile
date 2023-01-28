# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=bash

# include core basic info
include ../../config_build.mk

ifneq ($(wildcard ../../console.mk),)
include ../../console.mk
endif

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_FPGA_DIR=$(REMOTE_BUILD_DIR)/hardware/fpga
EMB_DIR = ../../software/embedded
PYTHON_DIR = ../../scripts

#select board
#default board
BOARD?=CYCLONEV-GT-DK

#include local fpga segment
ifneq ($(wildcard fpga_build.mk),)
include fpga_build.mk
endif

FPGA_TOOL:=$(shell find . -name $(BOARD) | cut -d"/" -f2)
include $(FPGA_TOOL)/$(FPGA_TOOL).mk
include $(FPGA_TOOL)/$(BOARD)/board.mk

#include the module's headers and sources
VHDR=$(wildcard ../src/*.vh)
VSRC+=$(wildcard ../src/*.v)

ifneq ($(wildcard $(FPGA_TOOL)/$(BOARD)/$(NAME)_fpga_wrapper.v),)
VSRC+=$(FPGA_TOOL)/$(BOARD)/$(NAME)_fpga_wrapper.v
endif

#
# Running parameters
#

#board UART baud rate and core frequency of operation
BAUD=$(BOARD_BAUD)
FREQ=$(BOARD_FREQ)

#disable external memory initialization 
ifeq ($(RUN_EXTMEM),1)
INIT_MEM=0
endif


#console start command
CONSOLE_CMD=$(PYTHON_DIR)/console.py -s /dev/usb-uart
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif

#RULES

HEX:=$(NAME)_boot.hex
ifeq ($(INIT_MEM),1)
HEX+=$(NAME)_firmware.hex
endif

#
# Board access queue
#

QUEUE_FILE=/tmp/$(BOARD).queue

#build fpga image or netlist
build: $(VHDR) $(VSRC) $(HEX)
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(FPGA_SYNC_FLAGS) -avz --delete --force ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD)'
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_FPGA_DIR)/$(FPGA_OBJ) .
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_FPGA_DIR)/$(FPGA_LOG) .
endif

FPGA_PROG?=echo 'FPGA programming tool is not set. Should be set in $(FPGA_TOOL).mk.'
#run fpga image
run: build
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	cp $(EMB_DIR)/$(NAME)_firmware.bin .
	bash -c "trap 'make queue-out' INT TERM KILL; make queue-in; $(FPGA_PROG); $(CONSOLE_CMD) | tee run.log; make queue-out;"
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(BOARD_SYNC_FLAGS) -avz --delete --force ../.. $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	bash -c "trap 'make queue-out-remote' INT TERM KILL; ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD)'"
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_FPGA_DIR)/run.log .
endif
endif

clean: $(FPGA_TOOL)-clean
	find . -maxdepth 1 -type f -not \( -name "Makefile" -o -name "fpga_build.mk" \) -delete
	@rm -f ../../*.vh
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'if [ -f $(REMOTE_FPGA_DIR)/Makefile ]; then make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD); fi'
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_SSH_FLAGS) $(BOARD_USER)@$(BOARD_SERVER) 'if [ -f $(REMOTE_FPGA_DIR)/Makefile ]; then make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD); fi'
endif
endif

test: debug $(TEST_LIST)

debug:
	@echo SIMULATOR=$(SIMULATOR)
	@echo BOARD=$(BOARD)
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo FPGA_SERVER=$(FPGA_SERVER)
	@echo FPGA_OBJ=$(FPGA_OBJ)
	@echo TEST_LIST=$(TEST_LIST)

queue-in:
	if [ ! -f $(QUEUE_FILE) ]; then touch $(QUEUE_FILE); chown $(USER):dialout $(QUEUE_FILE); chmod 664 $(QUEUE_FILE); fi;\
	if [ "`head -1 $(QUEUE_FILE)`" != "$(JOB)" ]; then echo $(JOB) >> $(QUEUE_FILE); fi;\
	bash -c "trap 'make queue-out; exit' INT TERM KILL; make queue-wait"

queue-wait:
	while [ "`head -1 $(QUEUE_FILE)`" != "$(JOB)" ]; do echo "Job queued for board access. Queue length: `wc -l $(QUEUE_FILE) | cut -d" " -f1`"; sleep 10s; done

queue-out:
	make kill-cnsl
	sed '/$(JOB)/d' $(QUEUE_FILE) > queue; cat queue > $(QUEUE_FILE); rm queue

queue-out-remote:
ifeq ($(BOARD_SERVER),)
	make queue-out
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_FPGA_DIR)/$(TOOL)/$(BOARD) queue-out'
endif



.PRECIOUS: $(FPGA_OBJ) test.log s_fw.bin

.PHONY: run build \
	queue-in queue-out queue-wait queue-out-remote \
	test clean debug

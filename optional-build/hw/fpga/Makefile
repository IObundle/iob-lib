# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=/bin/bash

# include core basic info
include ../../info_build.mk

REMOTE_BUILD_DIR=sandbox/$(NAME)


#include local fpga segment
ifneq ($(wildcard fpga.mk),)
include fpga.mk
endif

#include the module's headers and sources
VHDR=$(wildcard ../vsrc/*.vh)
VSRC+=$(wildcard ../vsrc/*.v)

include fpga_tool.mk

#build fpga image or netlist
build: $(VHDR) $(VSRC) $(HEX)
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(FPGA_SYNC_FLAGS) -avz --delete --force ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hw/fpga $@ TOP_MODULE=$(TOP_MODULE)'
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/hw/fpga/$(FPGA_OBJ) .
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/hw/fpga/$(FPGA_TEX) .
endif


#run fpga image
run:
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	cp $(FIRM_DIR)/firmware.bin .
	bash -c "trap 'make queue-out' INT TERM KILL; make queue-in; ../prog.sh; $(CONSOLE_CMD) | tee run.log; make queue-out;"
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	bash -c "trap 'make queue-out-remote' INT TERM KILL; ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/fpga/$(FPGA_TOOL)/$(BOARD) $@ INIT_MEM=$(INIT_MEM)'"
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)/hardware/fpga/$(FPGA_TOOL)/run.log .
endif
endif

clean:
	@find . -maxdepth 1 -type d -not \( -name '.' \) -exec rm -rf {} \;
	@find . -type f -not \( -name "Makefile" -o -name "*.mk" -o -name "*.expected" -o -name "*.tcl" -o -name "*.sdc" -o -name "*.xdc" -o -name test.log \) -delete
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'if [ -f $(REMOTE_BUILD_DIR)/hw/fpga/Makefile ]; then make -C $(REMOTE_BUILD_DIR)/hw/fpga clean; fi'
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/fpga/$(FPGA_TOOL) clean'
endif
endif

test: $(TEST_LIST)
	diff test.log test.expected

debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(FPGA_SERVER)
	@echo $(FPGA_OBJ)

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
CONSOLE_CMD=$(PYTHON_DIR)/console -s /dev/usb-uart
ifeq ($(INIT_MEM),0)
CONSOLE_CMD+=-f
endif


#RULES

HEX:=boot.hex
ifeq ($(INIT_MEM),1)
HEX+=firmware.hex
endif

#
# Board access queue
#

QUEUE_FILE=/tmp/$(BOARD).queue

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
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/fpga/$(TOOL)/$(BOARD) queue-out'
endif



.PRECIOUS: $(FPGA_OBJ) test.log s_fw.bin

.PHONY: run build \
	queue-in queue-out queue-wait queue-out-remote \
	test clean-remote clean debug

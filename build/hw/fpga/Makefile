# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=/bin/bash

# include core basic info
include ../../info.mk
ifneq ($(wildcard ../../config.mk),)
include ../../config.mk
endif


#include local fpga segment
ifneq ($(wildcard fpga.mk),)
include fpga.mk
endif

REMOTE_BUILD_DIR=sandbox/$(NAME)

#include the module's headers and sources
VHDR=$(wildcard ../vsrc/*.vh)
VSRC+=$(wildcard ../vsrc/*.v)

#select FPGA part and family
#default FPGA_FAMILY
FPGA_FAMILY?=CYCLONEV-GT
ifeq ($(FPGA_FAMILY),XCKU)
FPGA_PART:=xcku040-fbva676-1-c
include vivado.mk
else
#default part
FPGA_PART:=5CGTFD9E5F35C7
include quartus.mk
endif

build: $(VHDR) $(VSRC) $(HEX)
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(FPGA_SYNC_FLAGS) -avz --force ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hw/fpga $@ TOP_MODULE=$(TOP_MODULE) FPGA_FAMILY=$(FPGA_FAMILY)'
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/hw/fpga/$(FPGA_OBJ) .
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/hw/fpga/$(FPGA_TEX) .
endif


run:
ifeq ($(NORUN),0)
ifeq ($(BOARD_SERVER),)
	cp $(FIRM_DIR)/firmware.bin .
	if [ ! -f $(LOAD_FILE) ]; then touch $(LOAD_FILE); chown $(USER):dialout $(LOAD_FILE); chmod 664 $(LOAD_FILE); fi;\
	bash -c "trap 'make queue-out' INT TERM KILL; make queue-in; if [ $(FORCE) = 1 -o \"`head -1 $(LOAD_FILE)`\" != \"$(JOB)\" ];\
	then ../prog.sh; echo $(JOB) > $(LOAD_FILE); fi; $(CONSOLE_CMD) $(TEST_LOG); make queue-out;"
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	bash -c "trap 'make queue-out-remote' INT TERM KILL; ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/fpga/$(TOOL)/$(BOARD) $@ INIT_MEM=$(INIT_MEM) FORCE=$(FORCE) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)/hardware/fpga/$(TOOL)/$(BOARD)/test.log .
endif
endif
endif



#clean
clean:
	@find . -maxdepth 1 -type d -not \( -name '.' \) -exec rm -rf {} \;
	@find . -type f -not \( -name "Makefile" -o -name "*.mk" -o -name "*.expected" -o -name "*.tcl" -o -name "*.sdc" -o -name "*.xdc" \) -delete

ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'if [ -f $(REMOTE_BUILD_DIR)/hw/fpga/Makefile ]; then make -C $(REMOTE_BUILD_DIR)/hw/fpga clean; fi'

ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/fpga/$(TOOL)/$(BOARD) clean'
endif
endif


#
# Clean
#


#test
test: clean clean-test-log $(TEST_LIST)
	diff test.log test.expected

clean-test-log:
	rm -f test.log

debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(FPGA_SERVER)
	@echo $(FPGA_OBJ)









BAUD=$(BOARD_BAUD)
FREQ=$(BOARD_FREQ)

LOAD_FILE=/tmp/$(BOARD).load
QUEUE_FILE=/tmp/$(BOARD).queue
TOOL=$(shell find $(HW_DIR)/fpga -name $(BOARD) | cut -d"/" -f7)
JOB=$(shell echo $(USER) `md5sum $(FPGA_OBJ)  | cut -d" " -f1`)

ifeq ($(RUN_EXTMEM),1)
INIT_MEM=0
endif




#console command
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



#clean test log only when board testing begins
clean-testlog:
	@rm -f *.log
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --force --exclude .git $(ROOT_DIR) $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/fpga/$(TOOL)/$(BOARD) $@'
endif


.PRECIOUS: $(FPGA_OBJ) test.log s_fw.bin

.PHONY: run build \
	queue-in queue-out queue-wait queue-out-remote \
	test clean-all clean-testlog clean debug

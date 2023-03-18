# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=bash

#select board
#default board
BOARD ?=CYCLONEV-GT-DK

include ../../config_build.mk

ifneq ($(wildcard ../../console.mk),)
include ../../console.mk
endif

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_FPGA_DIR=$(REMOTE_BUILD_DIR)/hardware/fpga
EMB_DIR = ../../software/embedded
PYTHON_DIR = ../../scripts
FPGA_TOOL:=$(shell find . -name $(BOARD) | cut -d"/" -f2)

#include local fpga build segment
ifneq ($(wildcard fpga_build.mk),)
include fpga_build.mk
endif

FPGA_TOP ?=$(NAME)_fpga_wrapper

ifeq ($(FPGA_TOOL),)
$(error Cannot find FPGA toolchain for board $(BOARD). Please make sure that the board name is correct and that the board is supported by the FPGA toolchain)
endif

include $(FPGA_TOOL)/$(BOARD)/board.mk
include $(FPGA_TOOL)/build.mk

#include the module's headers and sources
VHDR = $(wildcard ../src/*.vh) $(wildcard ./src/*.vh)
VSRC += $(wildcard ../src/*.v) $(wildcard ./src/*.v)

ifneq ($(wildcard $(FPGA_TOOL)/$(BOARD)/$(NAME)_fpga_wrapper.v),)
VSRC+=$(FPGA_TOOL)/$(BOARD)/$(NAME)_fpga_wrapper.v
endif

UFLAGS+=FPGA_TOP=$(FPGA_TOP)
UFLAGS+=IS_FPGA=$(IS_FPGA)
UFLAGS+=USE_QUARTUS_PRO=$(USE_QUARTUS_PRO)

#build fpga image or netlist
build: $(VHDR) $(VSRC) $(HEX)
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(FPGA_SYNC_FLAGS) -avz --delete --force ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD) $(UFLAGS)'
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_FPGA_DIR)/$(FPGA_OBJ) .
	scp -r $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_FPGA_DIR)/reports .
ifneq ($(FPGA_STUB),)
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_FPGA_DIR)/$(FPGA_STUB) .
endif
endif

#console start command
CONSOLE_CMD=$(PYTHON_DIR)/console.py -s /dev/usb-uart
GRAB_CMD=while $(PYTHON_DIR)/board_client.py grab $(USER) | grep "busy" --color=never; do sleep 10; done
RELEASE_CMD=$(PYTHON_DIR)/board_client.py release $(USER)

#run fpga image
run: build
ifneq ($(NORUN),1)
ifeq ($(BOARD_SERVER),)
	cp $(EMB_DIR)/$(NAME)_firmware.bin .
	bash -c "trap '$(RELEASE_CMD)' INT TERM KILL; $(GRAB_CMD); $(FPGA_PROG); $(CONSOLE_CMD); $(RELEASE_CMD);"
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(BOARD_SYNC_FLAGS) -avz --delete --force ../.. $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_BUILD_DIR)
	bash -c "trap 'make -s release' INT TERM KILL; ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD) $(UFLAGS)'"
	scp $(BOARD_USER)@$(BOARD_SERVER):$(REMOTE_FPGA_DIR)/test.log .
endif
endif

release:
ifeq ($(FPGA_SERVER),)
	make kill-cnsl
	$(RELEASE_CMD)
else
	ssh $(BOARD_USER)@$(BOARD_SERVER) 'make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD)'
endif

clean: $(FPGA_TOOL)-clean
	find . -maxdepth 1 -type f -not \( -name "Makefile" -o -name "fpga_build.mk" \) -delete
	@rm -rf resynthesis *.hex
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'if [ -f $(REMOTE_FPGA_DIR)/Makefile ]; then make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD); fi'
ifneq ($(BOARD_SERVER),)
	ssh $(BOARD_SSH_FLAGS) $(BOARD_USER)@$(BOARD_SERVER) 'if [ -f $(REMOTE_FPGA_DIR)/Makefile ]; then make -C $(REMOTE_FPGA_DIR) $@ BOARD=$(BOARD); fi'
endif
endif

test: debug $(TEST_LIST)
	diff test.log test.expected

debug:
	@echo SIMULATOR=$(SIMULATOR)
	@echo BOARD=$(BOARD)
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo FPGA_SERVER=$(FPGA_SERVER)
	@echo FPGA_OBJ=$(FPGA_OBJ)
	@echo TEST_LIST=$(TEST_LIST)

.PRECIOUS: $(FPGA_OBJ) test.log s_fw.bin

.PHONY: run build test clean debug

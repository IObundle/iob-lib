# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile creates a build directory for an IP core
#
# It should be called from the user core repository directory which is
# assumed to be located at ../.. and have iob-lib as submodule called LIB.
#
# The user core repository is assumed to have the structure typical of
# IObundle's repositories

SHELL=/bin/bash
export

# core path
CORE_DIR=../..

# core info
include $(CORE_DIR)/info.mk

# core internal paths
CORE_HW_DIR=$(CORE_DIR)/hardware
CORE_SIM_DIR=$(CORE_HW_DIR)/simulation
CORE_FPGA_DIR=$(CORE_HW_DIR)/fpga


# make version header
VERSION_STR:=$(shell software/python/version.py $(NAME) $(VERSION))

# establish build dir paths
BUILD_DIR := $(CORE_DIR)/$(TOP_MODULE)_$(VERSION_STR)
BUILD_SRC_DIR:=$(BUILD_DIR)/vsrc
BUILD_SIM_DIR:=$(BUILD_DIR)/sim
BUILD_FPGA_DIR:=$(BUILD_DIR)/fpga
BUILD_DOC_DIR:=$(BUILD_DIR)/doc
BUILD_SYN_DIR:=$(BUILD_DIR)/syn

# creat build directory
$(BUILD_DIR):
	cp -r build $@

# import core hardware 
include $(CORE_DIR)/hardware/hardware.mk

# copy core version header file
VHDR+=$(BUILD_SRC_DIR)/$(NAME)_version.vh
$(BUILD_SRC_DIR)/$(NAME)_version.vh: $(NAME)_version.vh
	cp $< $@

setup: $(BUILD_DIR) $(VHDR) $(VSRC)
	cp $(CORE_DIR)/info.mk $(BUILD_DIR)
	echo "VERSION_STR=$(VERSION_STR)" > $(BUILD_DIR)/version.mk
	cp $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
	if [ "`ls $(CORE_SIM_DIR)/*.mk 2>/dev/null`" ]; then cp $(CORE_SIM_DIR)/*.mk $(BUILD_SIM_DIR); fi
	if [ "`ls $(CORE_SIM_DIR)/*_tb.* 2>/dev/null`" ]; then cp $(CORE_SIM_DIR)/*_tb.* $(BUILD_SRC_DIR); fi
	cp $(CORE_FPGA_DIR)/*.expected $(BUILD_FPGA_DIR)
	if [ "`ls $(CORE_FPGA_DIR)/*.mk 2>/dev/null`" ]; then cp $(CORE_FPGA_DIR)/*.mk $(BUILD_FPGA_DIR); fi
	if [ "`ls $(CORE_FPGA_DIR)/*.sdc 2>/dev/null`" ]; then cp $(CORE_FPGA_DIR)/*.sdc $(BUILD_FPGA_DIR); fi
	if [ "`ls $(CORE_FPGA_DIR)/*.xdc 2>/dev/null`" ]; then cp $(CORE_FPGA_DIR)/*.xdc $(BUILD_FPGA_DIR); fi


clean:
	if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
	@rm -f $(CORE_DIR)/*.vh *.vh

debug: $(BUILD_DIR) $(VHDR) $(VSRC)
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(VERSION_STR)
	@echo $(BUILD_DIR)
	@echo $(BUILD_SRC_DIR)
	@echo $(VHDR)
	@echo $(VSRC1)
	@echo $(VSRC2)
	@echo $(VSRC)
	@echo $(BUILD_SRC_DIR)

.PHONY: version setup clean debug

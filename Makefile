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
CORE_DOC_DIR=$(CORE_DIR)/document


# make version header
VERSION_STR:=$(shell software/python/version.py $(NAME) $(VERSION))

# establish build dir paths
BUILD_DIR := $(CORE_DIR)/$(NAME)_$(VERSION_STR)
BUILD_VSRC_DIR:=$(BUILD_DIR)/hw/vsrc
BUILD_SIM_DIR:=$(BUILD_DIR)/hw/sim
BUILD_FPGA_DIR:=$(BUILD_DIR)/hw/fpga
BUILD_DOC_DIR:=$(BUILD_DIR)/doc
BUILD_TSRC_DIR:=$(BUILD_DOC_DIR)/tsrc
BUILD_FIG_DIR:=$(BUILD_DOC_DIR)/figures
BUILD_SYN_DIR:=$(BUILD_DIR)/hw/syn

# creat build directory
$(BUILD_DIR):
	cp -r build $@

# import core hardware 
include $(CORE_DIR)/hardware/hardware.mk

# copy core version header file
VHDR+=$(BUILD_VSRC_DIR)/$(NAME)_version.vh
$(BUILD_VSRC_DIR)/$(NAME)_version.vh: $(NAME)_version.vh
	cp $< $@

setup: $(BUILD_DIR) $(VHDR) $(VSRC)
	echo "VERSION_STR=$(VERSION_STR)" > $(BUILD_DIR)/version.mk
	cp $(CORE_DIR)/info.mk $(BUILD_DIR)
ifneq ($(wildcard $(CORE_DIR)/mkregs.conf),)
	cp $(CORE_DIR)/mkregs.conf $(BUILD_TSRC_DIR)
endif
	cp $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
ifneq ($(wildcard $(CORE_SIM_DIR)/*.mk),)
	cp $(CORE_SIM_DIR)/*.mk $(BUILD_SIM_DIR)
endif 
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.mk),)
	cp $(CORE_FPGA_DIR)/*.mk $(BUILD_FPGA_DIR)
endif
	cp $(CORE_SIM_DIR)/*_tb.* $(BUILD_VSRC_DIR)
	cp $(CORE_FPGA_DIR)/*.expected $(BUILD_FPGA_DIR)
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.sdc),)
	cp $(CORE_FPGA_DIR)/*.sdc $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.xdc),)
	cp $(CORE_FPGA_DIR)/*.xdc $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(CORE_DOC_DIR)/*.mk),)
	cp $(CORE_DOC_DIR)/*.mk $(BUILD_DOC_DIR)
endif
	cp $(CORE_DOC_DIR)/*.tex $(BUILD_TSRC_DIR)
	cp $(CORE_DOC_DIR)/figures/* $(BUILD_FIG_DIR)



clean:
	if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
	@rm -f $(CORE_DIR)/*.vh *.vh

debug: $(BUILD_DIR) $(VHDR) $(VSRC)
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(VERSION_STR)
	@echo $(BUILD_DIR)
	@echo $(BUILD_VSRC_DIR)
	@echo $(VHDR)
	@echo $(VSRC1)
	@echo $(VSRC2)
	@echo $(VSRC)
	@echo $(BUILD_VSRC_DIR)

.PHONY: version setup clean debug

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used to setup a build directory for an IP core
#

SHELL=/bin/bash
export

LIB_DIR=submodules/LIB

include info.mk
include config_setup.mk

# lib paths
LIB_PYTHON_DIR=software/python


# enable all flows in setup by default
SETUP_SW ?=1
SETUP_SIM ?=1
SETUP_FPGA ?=1
SETUP_DOC ?=1

# core internal paths
SW_DIR=software
EMB_DIR=$(SW_DIR)/embedded
PC_DIR=$(SW_DIR)/pc-emul

HW_DIR=hardware
SIM_DIR=$(HW_DIR)/simulation
FPGA_DIR=$(HW_DIR)/fpga
DOC_DIR=document


# establish build dir paths
VERSION_STR := $(shell $(LIB_DIR)/software/python/version.py -i .)

BUILD_DIR := $(NAME)_$(VERSION_STR)
BUILD_SW_DIR:=$(BUILD_DIR)/sw
BUILD_SW_PYTHON_DIR:=$(BUILD_SW_DIR)/python
BUILD_SW_SRC_DIR:=$(BUILD_DIR)/sw/src
BUILD_SW_BSRC_DIR:=$(BUILD_DIR)/sw/bsrc
BUILD_SW_PC_DIR:=$(BUILD_SW_DIR)/pc
BUILD_SW_PCSRC_DIR:=$(BUILD_DIR)/sw/pcsrc
BUILD_SW_EMB_DIR:=$(BUILD_SW_DIR)/emb
BUILD_VSRC_DIR:=$(BUILD_DIR)/hw/vsrc
BUILD_SIM_DIR:=$(BUILD_DIR)/hw/sim
BUILD_FPGA_DIR:=$(BUILD_DIR)/hw/fpga
BUILD_DOC_DIR:=$(BUILD_DIR)/doc
BUILD_TSRC_DIR:=$(BUILD_DOC_DIR)/tsrc
BUILD_FIG_DIR:=$(BUILD_DOC_DIR)/figures
BUILD_SYN_DIR:=$(BUILD_DIR)/hw/syn

all: setup

# create build directory
$(BUILD_DIR):
	cp -r -u $(LIB_DIR)/build $@
ifeq ($(SETUP_SW),0)
	rm -rf $(BUILD_SW_DIR)
endif
ifeq ($(SETUP_SIM),0)
	rm -rf $(BUILD_SIM_DIR)
endif
ifeq ($(SETUP_FPGA),0)
	rm -rf $(BUILD_FPGA_DIR)
endif
ifeq ($(SETUP_DOC),0)
	rm -rf $(BUILD_DOC_DIR)
else
ifneq ($(wildcard mkregs.conf),)
	cp -u mkregs.conf $(BUILD_TSRC_DIR)
endif
endif
	cp -u info.mk $(BUILD_DIR)
	cp -u config_setup.mk $(BUILD_DIR)
ifneq ($(wildcard config.mk),)
	cp -u config.mk $(BUILD_DIR)
endif

# import core hardware and simulation files
include $(HW_DIR)/hardware.mk
include $(SIM_DIR)/sim_setup.mk

# import core software files
include $(SW_DIR)/software.mk

# import document files
ifneq ($(SETUP_DOC),0)
include $(DOC_DIR)/doc_setup.mk
endif

setup: $(BUILD_DIR) $(SRC)
ifneq ($(SETUP_SW),0)
ifneq ($(wildcard $(PC_DIR)/*.expected),)
	cp -u $(PC_DIR)/*.expected $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(PC_DIR)/pc-emul.mk),)
	cp -u $(PC_DIR)/pc-emul.mk $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(EMB_DIR)/embedded.mk),)
	cp -u $(EMB_DIR)/embedded.mk $(BUILD_SW_EMB_DIR)
endif
endif
ifneq ($(SETUP_SIM),0)
	cp -u $(SIM_DIR)/*.expected $(BUILD_SIM_DIR)
ifneq ($(wildcard $(SIM_DIR)/simulation.mk),)
	cp -u $(SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(SIM_DIR)/*.cpp),)
	cp -u $(SIM_DIR)/*.cpp $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(SIM_DIR)/*.v),)
	cp -u $(SIM_DIR)/*.v $(BUILD_SIM_DIR)
endif
endif
ifneq ($(SETUP_FPGA),0)
	cp -u $(FPGA_DIR)/*.expected $(BUILD_FPGA_DIR)
ifneq ($(wildcard $(FPGA_DIR)/*.mk),)
	cp -u $(FPGA_DIR)/*.mk $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(FPGA_DIR)/*.sdc),)
	cp -u $(FPGA_DIR)/*.sdc $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(FPGA_DIR)/*.xdc),)
	cp -u $(FPGA_DIR)/*.xdc $(BUILD_FPGA_DIR)
endif
endif
ifneq ($(SETUP_DOC),0)
	cp -u $(DOC_DIR)/*.expected $(BUILD_DOC_DIR)
ifneq ($(wildcard $(DOC_DIR)/*.mk),)
	cp -u $(DOC_DIR)/*.mk $(BUILD_DOC_DIR)
endif
ifneq ($(wildcard $(DOC_DIR)/*.tex),)
	cp -f $(DOC_DIR)/*.tex $(BUILD_TSRC_DIR)
endif
	cp -u $(DOC_DIR)/figures/* $(BUILD_FIG_DIR)
	cp -u $(LIB_DIR)/software/python/verilog2tex.py $(BUILD_SW_PYTHON_DIR)
	cp -u $(LIB_DIR)/software/python/mkregs.py $(BUILD_SW_PYTHON_DIR)
endif

clean:
	@if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
	@rm -rf software/python/__pycache__

debug: $(BUILD_DIR) $(VHDR) 
	@echo $(NAME)
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(VERSION_STR)
	@echo $(BUILD_DIR)
	@echo $(BUILD_VSRC_DIR)
	@echo $(BUILD_SW_SRC_DIR)
	@echo $(SRC)

.PHONY: all setup clean debug

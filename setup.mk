# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used to setup a build directory for an IP core
#

SHELL=/bin/bash
export

LIB_DIR=submodules/LIB
CORE_DIR =.

include $(CORE_DIR)/info.mk
include $(CORE_DIR)/config_setup.mk

# lib paths
LIB_PYTHON_DIR=software/python


# enable all flows in setup by default
SETUP_SW ?=1
SETUP_SIM ?=1
SETUP_FPGA ?=1
SETUP_DOC ?=1

# core internal paths
CORE_SW_DIR=$(CORE_DIR)/software
CORE_EMB_DIR=$(CORE_SW_DIR)/embedded
CORE_PC_DIR=$(CORE_SW_DIR)/pc-emul

CORE_HW_DIR=$(CORE_DIR)/hardware
CORE_SIM_DIR=$(CORE_HW_DIR)/simulation
CORE_FPGA_DIR=$(CORE_HW_DIR)/fpga
CORE_DOC_DIR=$(CORE_DIR)/document


# establish build dir paths
VERSION_STR := $(shell $(LIB_DIR)/software/python/version.py -i $(CORE_DIR))

BUILD_DIR := $(CORE_DIR)/$(NAME)_$(VERSION_STR)
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
	cp -u $(CORE_DIR)/info.mk $(BUILD_DIR)
	cp -u $(CORE_DIR)/config_setup.mk $(BUILD_DIR)
ifneq ($(wildcard $(CORE_DIR)/config.mk),)
	cp -u $(CORE_DIR)/config.mk $(BUILD_DIR)
endif
ifneq ($(wildcard $(CORE_DIR)/mkregs.conf),)
	cp -u $(CORE_DIR)/mkregs.conf $(BUILD_TSRC_DIR)
endif

# import core hardware and simulation files
include $(CORE_HW_DIR)/hardware.mk
include $(CORE_SIM_DIR)/sim_setup.mk

# import core software files
include $(CORE_SW_DIR)/software.mk

# import document files
ifneq ($(SETUP_DOC),0)
include $(CORE_DOC_DIR)/doc_setup.mk
endif

setup: $(BUILD_DIR) $(SRC)
ifneq ($(SETUP_SW),0)
ifneq ($(wildcard $(CORE_PC_DIR)/*.expected),)
	cp -u $(CORE_PC_DIR)/*.expected $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(CORE_PC_DIR)/pc-emul.mk),)
	cp -u $(CORE_PC_DIR)/pc-emul.mk $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(CORE_EMB_DIR)/embedded.mk),)
	cp -u $(CORE_EMB_DIR)/embedded.mk $(BUILD_SW_EMB_DIR)
endif
endif
ifneq ($(SETUP_SIM),0)
	cp -u $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
ifneq ($(wildcard $(CORE_SIM_DIR)/simulation.mk),)
	cp -u $(CORE_SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(CORE_SIM_DIR)/*_tb.*),)
	cp -u $(CORE_SIM_DIR)/*_tb.* $(BUILD_SIM_DIR)
endif
endif
ifneq ($(SETUP_FPGA),0)
	cp -u $(CORE_FPGA_DIR)/*.expected $(BUILD_FPGA_DIR)
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.mk),)
	cp -u $(CORE_FPGA_DIR)/*.mk $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.sdc),)
	cp -u $(CORE_FPGA_DIR)/*.sdc $(BUILD_FPGA_DIR)
endif
ifneq ($(wildcard $(CORE_FPGA_DIR)/*.xdc),)
	cp -u $(CORE_FPGA_DIR)/*.xdc $(BUILD_FPGA_DIR)
endif
endif
ifneq ($(SETUP_DOC),0)
	cp -u $(CORE_DOC_DIR)/*.expected $(BUILD_DOC_DIR)
ifneq ($(wildcard $(CORE_DOC_DIR)/*.mk),)
	cp -u $(CORE_DOC_DIR)/*.mk $(BUILD_DOC_DIR)
endif
ifneq ($(wildcard $(CORE_DOC_DIR)/*.tex),)
	cp -f $(CORE_DOC_DIR)/*.tex $(BUILD_TSRC_DIR)
endif
	cp -u $(CORE_DOC_DIR)/figures/* $(BUILD_FIG_DIR)
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

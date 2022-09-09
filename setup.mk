# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used to setup a build directory for an IP core
#

SHELL=/bin/bash
export

LIB_DIR=submodules/LIB

include info.mk

# lib paths
LIB_PYTHON_DIR=software/python


# core internal paths
SW_DIR=software
EMB_DIR=$(SW_DIR)/embedded
PC_DIR=$(SW_DIR)/pc-emul

HW_DIR=hardware
SIM_DIR=$(HW_DIR)/simulation
FPGA_DIR=$(HW_DIR)/fpga
DOC_DIR=document

# FPGA compiler
FPGA_TOOL=$(shell find $(LIB_DIR)/hardware/boards -name $(BOARD) | cut -d"/" -f5)

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

# EXCLUDE_BUILD+=--exclude sw
# EXCLUDE_BUILD+=--exclude hw/sim
# EXCLUDE_BUILD+=--exclude hw/fpga
# EXCLUDE_BUILD+=--exclude doc

# create build directory
$(BUILD_DIR):
	# rsync -a $(LIB_DIR)/build/* $@ $(EXCLUDE_BUILD)
	cp -r $(LIB_DIR)/build $(BUILD_DIR)
	cp info.mk $(BUILD_DIR)
ifneq ($(wildcard software/.),)
#--------------------- PC-EMUL-----------------------
	cp -r $(LIB_DIR)/optional-build/sw $(BUILD_SW_DIR)
ifneq ($(wildcard $(PC_DIR)/*.expected),)
	cp $(PC_DIR)/*.expected $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(PC_DIR)/pc-emul.mk),)
	cp $(PC_DIR)/pc-emul.mk $(BUILD_SW_PC_DIR)
endif
ifneq ($(wildcard $(EMB_DIR)/embedded.mk),)
	cp $(EMB_DIR)/embedded.mk $(BUILD_SW_EMB_DIR)
endif
endif
#--------------------- SIMULATION-----------------------
ifneq ($(wildcard hardware/simulation/.),)
	cp -r $(LIB_DIR)/optional-build/hw/sim $(BUILD_SIM_DIR)
ifneq ($(wildcard $(SIM_DIR)/*.expected),)
	cp $(SIM_DIR)/*.expected $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(SIM_DIR)/simulation.mk),)
	cp $(SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(SIM_DIR)/*.cpp),)
	cp $(SIM_DIR)/*.cpp $(BUILD_SIM_DIR)
endif
ifneq ($(wildcard $(SIM_DIR)/*.v),)
	cp $(SIM_DIR)/*.v $(BUILD_SIM_DIR)
endif
endif
#--------------------- FPGA-----------------------
ifneq ($(wildcard hardware/fpga/.),)
	cp -r $(LIB_DIR)/optional-build/hw/fpga $(BUILD_FPGA_DIR)
	cp -r $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(FPGA_TOOL).mk $(BUILD_FPGA_DIR)/fpga_tool.mk
	cp -r $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(FPGA_TOOL).tcl $(BUILD_FPGA_DIR)/fpga_tool.tcl
	cp -r $(LIB_DIR)/software/bash/$(FPGA_TOOL)2tex.sh $(BUILD_SW_DIR)/bash
	cp -r $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/* $(BUILD_FPGA_DIR)
ifneq ($(wildcard $(FPGA_DIR)/fpga.mk),)
	cp $(FPGA_DIR)/fpga.mk $(BUILD_FPGA_DIR)
endif
	cp $(FPGA_DIR)/$(FPGA_TOOL)/$(BOARD)/* $(BUILD_FPGA_DIR)
endif
#--------------------- DOCUMENT-----------------------
ifneq ($(wildcard document/.),)
	cp -r $(LIB_DIR)/optional-build/doc $(BUILD_DOC_DIR)
	git rev-parse --short HEAD > $(BUILD_TSRC_DIR)/shortHash.tex
ifneq ($(wildcard mkregs.conf),)
	cp mkregs.conf $(BUILD_TSRC_DIR)
endif
ifneq ($(wildcard $(DOC_DIR)/*.expected),)
	cp $(DOC_DIR)/*.expected $(BUILD_DOC_DIR)
endif
ifneq ($(wildcard $(DOC_DIR)/document.mk),)
	cp $(DOC_DIR)/document.mk $(BUILD_DOC_DIR)
endif
ifneq ($(wildcard $(DOC_DIR)/*.tex),)
	cp -f $(DOC_DIR)/*.tex $(BUILD_TSRC_DIR)
endif
	cp $(DOC_DIR)/figures/* $(BUILD_FIG_DIR)
	cp $(LIB_DIR)/software/python/verilog2tex.py $(BUILD_SW_PYTHON_DIR)
	cp $(LIB_DIR)/software/python/mkregs.py $(BUILD_SW_PYTHON_DIR)
endif

# import core hardware and simulation files
include $(HW_DIR)/hardware.mk
ifneq ($(wildcard $(SIM_DIR)/sim_setup.mk),)
include $(SIM_DIR)/sim_setup.mk
endif

# import core software files
include $(SW_DIR)/software.mk

# import document files
ifneq ($(wildcard document/doc_setup.mk),)
include $(DOC_DIR)/doc_setup.mk
endif

setup: $(BUILD_DIR) $(SRC)

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
	@echo $(SIMULATOR)
	@echo $(BOARD)
	@echo $(FPGA_TOOL)

.PHONY: all setup clean debug

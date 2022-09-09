# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used to setup a build directory for an IP core
#

SHELL=/bin/bash
export

LIB_DIR=submodules/LIB

include config_setup.mk

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

SRC+=$(BUILD_DIR)/info.mk
$(BUILD_DIR)/info.mk:
	echo "NAME=$(NAME)" > $@
	echo "TOP_MODULE?=$(TOP_MODULE)" >> $@
	echo "BOARD?=$(BOARD)" >> $@
	echo "SIMULATOR?=$(SIMULATOR)" >> $@

ifneq ($(wildcard software/.),)
#--------------------- PC-EMUL-----------------------
SRC+=$(BUILD_DIR)/sw
SRC+=$(BUILD_DIR)/sw/bash
SRC+=$(BUILD_DIR)/sw/bsrc
SRC+=$(BUILD_DIR)/sw/emb
SRC+=$(BUILD_DIR)/sw/pc
SRC+=$(BUILD_DIR)/sw/pcsrc
SRC+=$(BUILD_DIR)/sw/python
SRC+=$(BUILD_DIR)/sw/src
# create BUILD_DIR/sw directories
$(BUILD_DIR)/sw $(BUILD_DIR)/sw/bash $(BUILD_DIR)/sw/bsrc $(BUILD_DIR)/sw/emb $(BUILD_DIR)/sw/pc $(BUILD_DIR)/sw/pcsrc $(BUILD_DIR)/sw/python $(BUILD_DIR)/sw/src:
	mkdir -p $@

SRC+=$(BUILD_DIR)/sw/emb/Makefile
SRC+=$(BUILD_DIR)/sw/pc/Makefile
$(BUILD_DIR)/sw/%/Makefile: $(LIB_DIR)/software/%/Makefile
	cp $< $@

SRC+=$(patsubst $(PC_DIR)/%, $(BUILD_SW_PC_DIR)/%, $(wildcard $(PC_DIR)/*.expected))
$(BUILD_SW_PC_DIR)/%.expected: $(PC_DIR)/%.expected
	cp $< $@

SRC+=$(patsubst $(PC_DIR)/%, $(BUILD_SW_PC_DIR)/%, $(wildcard $(PC_DIR)/pc-emul.mk))
$(BUILD_SW_PC_DIR)/pc-emul.mk: $(PC_DIR)/pc-emul.mk
	cp $< $@

SRC+=$(patsubst $(EMB_DIR)/%, $(BUILD_SW_EMB_DIR)/%, $(wildcard $(EMB_DIR)/embedded.mk))
$(BUILD_SW_PC_DIR)/embedded.mk: $(EMB_DIR)/embedded.mk
	cp $< $@
endif
#--------------------- SIMULATION-----------------------
ifneq ($(wildcard hardware/simulation/.),)
SRC+=$(BUILD_SIM_DIR)
$(BUILD_SIM_DIR): $(LIB_DIR)/hardware/simulation
	cp -r $< $@

SRC+=$(patsubst $(LIB_DIR)/hardware/simulation/%, $(BUILD_SIM_DIR)/%, $(shell find $(LIB_DIR)/hardware/simulation))
$(BUILD_SIM_DIR)/%: $(LIB_DIR)/hardware/simulation/%
	cp $< $@

SRC+=$(patsubst $(SIM_DIR)/%, $(BUILD_SIM_DIR)/%, $(wildcard $(SIM_DIR)/*.expected))
$(BUILD_SIM_DIR)/%.expected: $(SIM_DIR)/%.expected
	cp $< $@

SRC+=$(patsubst $(SIM_DIR)/%, $(BUILD_SIM_DIR)/%, $(wildcard $(SIM_DIR)/simulation.mk))
$(BUILD_SIM_DIR)/simulation.mk: $(SIM_DIR)/simulation.mk
	cp $< $@

SRC+=$(patsubst $(SIM_DIR)/%, $(BUILD_SIM_DIR)/%, $(wildcard $(SIM_DIR)/*.cpp))
$(BUILD_SIM_DIR)/%.cpp: $(SIM_DIR)/%.cpp
	cp $< $@

SRC+=$(patsubst $(SIM_DIR)/%, $(BUILD_SIM_DIR)/%, $(wildcard $(SIM_DIR)/*.v))
$(BUILD_SIM_DIR)/%.v: $(SIM_DIR)/%.v
	cp $< $@
endif
#--------------------- FPGA-----------------------
ifneq ($(wildcard hardware/fpga/.),)
SRC+=$(BUILD_FPGA_DIR)
$(BUILD_FPGA_DIR): $(LIB_DIR)/hardware/fpga
	cp -r $< $@

SRC+=$(patsubst $(LIB_DIR)/hardware/fpga/%, $(BUILD_FPGA_DIR)/%, $(shell find $(LIB_DIR)/hardware/fpga))
$(BUILD_FPGA_DIR)/%: $(LIB_DIR)/hardware/fpga/%
	cp $< $@

SRC+=$(patsubst $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/%, $(BUILD_FPGA_DIR)/fpga_tool.mk, $(wildcard $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(FPGA_TOOL).mk))
$(BUILD_FPGA_DIR)/fpga_tool.mk: $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(FPGA_TOOL).mk
	cp $< $@

SRC+=$(patsubst $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/%, $(BUILD_FPGA_DIR)/fpga_tool.tcl, $(wildcard $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(FPGA_TOOL).tcl))
$(BUILD_FPGA_DIR)/fpga_tool.tcl: $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(FPGA_TOOL).tcl
	cp $< $@

SRC+=$(patsubst $(LIB_DIR)/software/bash/%, $(BUILD_SW_DIR)/bash/%, $(wildcard $(LIB_DIR)/software/bash/$(FPGA_TOOL)2tex.sh))
$(BUILD_SW_DIR)/bash/%: $(LIB_DIR)/software/bash/%
	cp $< $@

SRC+=$(patsubst $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/%, $(BUILD_DIR)/hw/fpga/%, $(wildcard $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/*))
$(BUILD_DIR)/hw/fpga/%: $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/%
	cp -r $< $@

SRC+=$(patsubst $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/%, $(BUILD_FPGA_DIR)/%, $(wildcard $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/*))
$(BUILD_FPGA_DIR)/%: $(LIB_DIR)/hardware/boards/$(FPGA_TOOL)/$(BOARD)/%
	cp -r $< $@

SRC+=$(patsubst $(FPGA_DIR)/%, $(BUILD_FPGA_DIR)/%, $(wildcard $(FPGA_DIR)/fpga.mk))
$(BUILD_FPGA_DIR)/fpga.mk: $(FPGA_DIR)/fpga.mk
	cp $< $@

SRC+=$(patsubst $(FPGA_DIR)/$(FPGA_TOOL)/$(BOARD)/%, $(BUILD_FPGA_DIR)/%, $(wildcard $(FPGA_DIR)/$(FPGA_TOOL)/$(BOARD)/*))
$(BUILD_FPGA_DIR)/%: $(FPGA_DIR)/$(FPGA_TOOL)/$(BOARD)/%
	cp -r $< $@

endif
#--------------------- DOCUMENT-----------------------
ifneq ($(wildcard document/.),)
SRC+=$(BUILD_DOC_DIR)
$(BUILD_DOC_DIR): $(LIB_DIR)/document
	cp -r $< $@

SRC+=$(patsubst $(LIB_DIR)/document/%, $(BUILD_DOC_DIR)/%, $(shell find $(LIB_DIR)/document))
$(BUILD_DOC_DIR)/%: $(LIB_DIR)/document/%
	cp $< $@

SRC+=$(BUILD_TSRC_DIR)/shortHash.tex
$(BUILD_TSRC_DIR)/shortHash.tex:
	git rev-parse --short HEAD > $@

SRC+=$(patsubst %, $(BUILD_TSRC_DIR)/%, $(wildcard mkregs.conf))
$(BUILD_TSRC_DIR)/mkregs.conf: mkregs.conf
	cp $< $@

SRC+=$(patsubst $(DOC_DIR)/%, $(BUILD_DOC_DIR)/%, $(wildcard $(DOC_DIR)/*.expected))
$(BUILD_DOC_DIR)/%.expected: $(DOC_DIR)/%.expected
	cp $< $@

SRC+=$(patsubst $(DOC_DIR)/%, $(BUILD_DOC_DIR)/%, $(wildcard $(DOC_DIR)/document.mk))
$(BUILD_DOC_DIR)/document.mk: $(DOC_DIR)/document.mk
	cp $< $@

SRC+=$(patsubst $(DOC_DIR)/%, $(BUILD_TSRC_DIR)/%, $(wildcard $(DOC_DIR)/*.tex))
$(BUILD_TSRC_DIR)/%: $(DOC_DIR)/%.tex
	cp $< $@

SRC+=$(patsubst $(DOC_DIR)/figures/%, $(BUILD_FIG_DIR)/%, $(wildcard $(DOC_DIR)/figures/*))
$(BUILD_FIG_DIR)/%: $(DOC_DIR)/figures/%
	cp $< $@

SRC+=$(BUILD_SW_PYTHON_DIR)/verilog2tex.py
$(BUILD_SW_PYTHON_DIR)/verilog2tex.py: $(LIB_DIR)/software/python/verilog2tex.py
	cp $< $@

SRC+=$(BUILD_SW_PYTHON_DIR)/mkregs.py
$(BUILD_SW_PYTHON_DIR)/mkregs.py: $(LIB_DIR)/software/python/mkregs.py
	cp $< $@
endif

all: setup

# create build directory
$(BUILD_DIR):
	cp -r $(LIB_DIR)/build $(BUILD_DIR)

# import core hardware files
ifneq ($(wildcard $(HW_DIR)/hw_setup.mk),)
include $(HW_DIR)/hw_setup.mk
endif

# import core simulation files
ifneq ($(wildcard $(SIM_DIR)/sim_setup.mk),)
include $(SIM_DIR)/sim_setup.mk
endif

# import core software files
ifneq ($(wildcard $(SW_DIR)/sw_setup.mk),)
include $(SW_DIR)/sw_setup.mk
endif

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

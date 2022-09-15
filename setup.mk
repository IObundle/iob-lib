# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

SHELL=/bin/bash
export

# include core setup configuration
LIB_DIR=submodules/LIB
include config_setup.mk

# FPGA compiler
#FPGA_TOOL=$(shell find $(LIB_DIR)/hardware/fpga -name $(BOARD) | cut -d"/" -f5)

# python scripts directory
PYTHON_DIR=$(LIB_DIR)/scripts

# create version string
VERSION_STR := $(shell $(PYTHON_DIR)/version.py -i .)

# establish build dir paths
BUILD_DIR := ../$(NAME)_$(VERSION_STR)
BUILD_VSRC_DIR := $(BUILD_DIR)/hardware/src
BUILD_SIM_DIR := $(BUILD_DIR)/hardware/simulation
BUILD_FPGA_DIR := $(BUILD_DIR)/hardware/fpga
BUILD_ESRC_DIR := $(BUILD_DIR)/software/emb
BUILD_DOC_DIR := $(BUILD_DIR)/document


setup: $(BUILD_DIR) sim-setup fpga-setup syn-setup software-setup doc-setup debug

$(BUILD_DIR):
	@rsync -avz --exclude .git --exclude submodules --exclude .gitmodules --exclude .github  . $(BUILD_DIR)
	echo "NAME=$(NAME)" > $(BUILD_DIR)/info.mk
	echo "VERSION=$(VERSION)" >> $(BUILD_DIR)/info.mk
	find $(BUILD_DIR) -name \*_setup.mk -delete
	cp $(LIB_DIR)/build.mk $(BUILD_DIR)/Makefile

#hardware

SRC+=$(BUILD_VSRC_DIR)/$(NAME)_version.vh
$(BUILD_VSRC_DIR)/$(NAME)_version.vh: config_setup.mk
	$(LIB_DIR)/scripts/version.py -v .
	mv $(NAME)_version.vh $(BUILD_VSRC_DIR)

ifneq ($(wildcard hardware/hw_setup.mk),)
include hardware/hw_setup.mk
endif

#simulation
ifneq ($(wildcard hardware/simulation),)

ifneq ($(wildcard hardware/simulation/sim_setup.mk),)
include hardware/simulation/sim_setup.mk
endif

sim-setup: $(BUILD_DIR) debug
	cp $(LIB_DIR)/hardware/simulation/* $(BUILD_SIM_DIR)

endif

#fpga
fpga-setup:
ifneq ($(wildcard hardware/fpga),)
	cp -rn $(LIB_DIR)/hardware/fpga/* $(BUILD_FPGA_DIR)
endif

#synthesis
syn-setup:
ifneq ($(wildcard hardware/synthesis),)
	cp -rn $(LIB_DIR)/hardware/synthesis/* $(BUILD_DIR)/hardware/synthesis
endif

#software
ifneq ($(wildcard software),)

ifneq ($(wildcard software/sw_setup.mk),)
include software/sw_setup.mk
endif

software-setup:
	cp -rn $(LIB_DIR)/software/emb/* $(BUILD_DIR)/software/emb
ifneq ($(wildcard software/pc-emul),)
	cp -rn $(LIB_DIR)/software/pc-emul/* $(BUILD_DIR)/software/pc-emul
endif

endif

#document
ifneq ($(wildcard document),)


# create and copy core version header files
SRC+=$(BUILD_DOC_DIR)/$(NAME)_version.tex
$(BUILD_DOC_DIR)/$(NAME)_version.tex:
	$(LIB_DIR)/scripts/version.py -t .
	mv iob_cache_version.tex $(BUILD_DOC_DIR)

# include local setup stub
ifneq ($(wildcard document/doc_setup.mk),)
include document/doc_setup.mk
endif

# select core configuration
SRC+=$(BUILD_VSRC_DIR)/$(NAME)_conf.vh
$(BUILD_VSRC_DIR)/$(NAME)_conf.vh:
	cp hardware/src/$(NAME)_conf_$(CACHE_CONFIG).vh $@

#generate tex files from code comments
ifneq ($(wildcard ../mkregs.conf),)
MKREGS_CONF:=mkregs.conf
endif
VHDR:=$(wildcard ../hardware/src/*.vh)
VSRC:=$(wildcard ../hardware/src/*.v)

#copy lib tex files if not present
SRC+=$(patsubst $(LIB_DIR)/document/tsrc/%.tex, $(BUILD_DOC_DIR)/tsrc/%.tex, $(wildcard $(LIB_DIR)/document/tsrc/*.tex))
$(BUILD_DOC_DIR)/tsrc/%.tex: $(LIB_DIR)/document/tsrc/%.tex
	if [ ! -f $@ ]; then cp $< $@; fi

SRC+=$(patsubst $(LIB_DIR)/document/tsrc/%.cls, $(BUILD_DOC_DIR)/tsrc/%.cls, $(wildcard $(LIB_DIR)/document/tsrc/*.cls))
$(BUILD_DOC_DIR)/tsrc/%.cls: $(LIB_DIR)/document/tsrc/%.cls
	if [ ! -f $@ ]; then cp $< $@; fi

doc-setup: $(SRC)
	$(PYTHON_DIR)/verilog2tex.py hardware/src/$(NAME).v $(VHDR) $(VSRC) $(MKREGS_CONF)
	mv *.tex $(BUILD_DOC_DIR)/tsrc
	cp $(LIB_DIR)/document/Makefile $(BUILD_DOC_DIR)
	cp $(LIB_DIR)/document/figures/* $(BUILD_DOC_DIR)/figures
endif


clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf scripts/__pycache__

debug: $(BUILD_DIR) $(SRC)
	@echo SRC=$(SRC)
	@echo $(filter iob_lib.vh, $(SRC))

.PHONY: setup sim-setup fpga-setup syn-setup sw-setup doc-setup debug

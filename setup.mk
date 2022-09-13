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

# create version string
VERSION_STR := $(shell $(LIB_DIR)/software/python/version.py -i .)

# establish build dir paths
BUILD_DIR := ../$(NAME)_$(VERSION_STR)
BUILD_VSRC_DIR := $(BUILD_DIR)/hardware/src
BUILD_SIM_DIR := $(BUILD_DIR)/hardware/simulation
BUILD_ESRC_DIR := $(BUILD_DIR)/software/emb


setup: debug sim-setup fpga-setup syn-setup software-setup doc-setup
	mv $(BUILD_DIR)/config_setup.mk $(BUILD_DIR)/info.mk
	find $(BUILD_DIR) -name \*_setup.mk -delete
	cp $(LIB_DIR)/build.mk $(BUILD_DIR)/Makefile

$(BUILD_DIR):
	@rsync -avz --exclude .git --exclude submodules --exclude .gitmodules --exclude .github  . $(BUILD_DIR)

#hardware
ifneq ($(wildcard hardware/hw_setup.mk),)
include hardware/hw_setup.mk
endif

#hardware
ifneq ($(wildcard hardware/simulation/sim_setup.mk),)
include hardware/simulation/sim_setup.mk
endif

sim-setup:
ifneq ($(wildcard hardware/simulation),)
	cp $(LIB_DIR)/hardware/simulation/* $(BUILD_DIR)/hardware/simulation
endif

fpga-setup:
ifneq ($(wildcard hardware/fpga),)
	cp $(LIB_DIR)/hardware/fpga/Makefile $(BUILD_DIR)/hardware/fpga
	cp -r $(LIB_DIR)/hardware/fpga/* $(BUILD_DIR)/hardware/fpga
endif

syn-setup:
ifneq ($(wildcard hardware/synthesis),)
	cp $(LIB_DIR)/hardware/synthesis/* $(BUILD_DIR)/hardware/synthesis
endif

#software
ifneq ($(wildcard software),)
include software/sw_setup.mk
endif

software-setup:
ifneq ($(wildcard software),)
ifneq ($(wildcard software/emb),)
	cp $(LIB_DIR)/software/emb/* $(BUILD_DIR)/software/emb
ifneq ($(wildcard software/pc-emul),)
	cp $(LIB_DIR)/software/pc-emul/* $(BUILD_DIR)/software/pc-emul
endif
endif
endif

#document
doc-setup:
ifneq ($(wildcard doc),)
	cp $(LIB_DIR)/doc/* $(BUILD_DIR)/doc
endif


clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf software/python/__pycache__

debug: $(BUILD_DIR) $(SRC)
	echo $(SRC)

.PHONY: set-up sim-setup fpga-setup syn-setup sw-setup doc-setup debug

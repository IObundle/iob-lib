# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

SHELL=bash
export

SETUP_PYTHON_FILENAME=$(wildcard *_setup.py)

# python scripts directory
PYTHON_DIR=submodules/LIB/scripts

#submodule directories
$(foreach entry, $(shell $(PYTHON_DIR)/setup.py get_core_submodules_dirs), $(eval $(entry)))
#
# core name
NAME:=$(shell $(PYTHON_DIR)/setup.py get_core_name)

# create version string
VERSION_STR:=$(shell $(PYTHON_DIR)/version.py -i .)

# build directory name
BUILD_DIR_NAME:=$(NAME)_$(VERSION_STR)

# establish build dir paths
BUILD_DIR := ../$(BUILD_DIR_NAME)

BUILD_FPGA_DIR = $(BUILD_DIR)/hardware/fpga
BUILD_SYN_DIR = $(BUILD_DIR)/hardware/syn
BUILD_LINT_DIR = $(BUILD_DIR)/hardware/lint

BUILD_ESRC_DIR = $(BUILD_DIR)/software/esrc
BUILD_DOC_DIR = $(BUILD_DIR)/document
BUILD_FIG_DIR = $(BUILD_DOC_DIR)/figures
BUILD_TSRC_DIR = $(BUILD_DOC_DIR)/tsrc


setup: debug

$(BUILD_DIR):
	./$(SETUP_PYTHON_FILENAME)
#
#HARDWARE
#
# include local setup makefile segment

#
#SOFTWARE
#
# include local setup makefile segment

#
#DOCUMENT
#

ifneq ($(wildcard document),)

#include local fpga makefile segment
ifneq ($(wildcard document/doc_setup.mk),)
include document/doc_setup.mk
endif

#make short git hash file
SRC+=$(BUILD_TSRC_DIR)/shortHash.tex
$(BUILD_TSRC_DIR)/shortHash.tex:
	git rev-parse --short HEAD > $@


#copy lib tex files if not present
SRC+=$(patsubst $(LIB_DIR)/document/tsrc/%, $(BUILD_TSRC_DIR)/%, $(wildcard $(LIB_DIR)/document/tsrc/*))
$(BUILD_TSRC_DIR)/%: $(LIB_DIR)/document/tsrc/%
	if [ ! -f $@ ]; then cp $< $@; fi

#copy figures from LIB
SRC+=$(patsubst $(LIB_DIR)/document/figures/%, $(BUILD_FIG_DIR)/%, $(wildcard $(LIB_DIR)/document/figures/*))
$(BUILD_FIG_DIR)/%: $(LIB_DIR)/document/figures/%
	cp $< $@

#copy document Makefile
SRC+=$(BUILD_DOC_DIR)/Makefile
$(BUILD_DOC_DIR)/Makefile: $(LIB_DIR)/document/Makefile
	cp $< $@

ifeq ($(INTEL_FPGA),1)
SRC+=$(BUILD_DIR)/doc/quartus.tex
endif

ifeq ($(AMD_FPGA),1)
$(BUILD_DIR)/doc/vivado.tex
endif

#
# DELIVERY 
#

ifneq ($(wildcard config_delivery.mk),)
include config_delivery.mk
endif


# generate quartus fitting results 
$(BUILD_DIR)/doc/quartus.tex:
	make -C $(BUILD_DIR) fpga-build BOARD=CYCLONEV-GT-DK
	LOG=$(BUILD_FPGA_DIR)/quartus.log $(LIB_DIR)/scripts/quartus2tex.sh
	mv `basename $@` $(BUILD_DOC_DIR)

# generate vivado fitting results 
$(BUILD_DIR)/doc/vivado.tex:
	make -C $(BUILD_DIR) fpga-build BOARD=AES-KU040-DB-G
	LOG=$(BUILD_FPGA_DIR)/vivado.log $(LIB_DIR)/scripts/vivado2tex.sh
	mv `basename $@` $(BUILD_DOC_DIR)

endif


clean:
	@rm -rf $(BUILD_DIR)
	@rm -rf scripts/__pycache__

python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune

debug: $(BUILD_DIR) $(SRC)
	@echo SRC=$(SRC)


.PHONY: setup clean debug

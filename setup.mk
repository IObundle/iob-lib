# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

SHELL=/bin/bash
export

# include core setup configuration
LIB_DIR=submodules/LIB
include config_setup.mk

# python scripts directory
PYTHON_DIR=$(LIB_DIR)/scripts

# create version string
VERSION_STR := $(shell $(PYTHON_DIR)/version.py -i .)

# build directory name
BUILD_DIR_NAME:=$(NAME)_$(VERSION_STR)

# establish build dir paths
BUILD_DIR := ../$(BUILD_DIR_NAME)

BUILD_VSRC_DIR = $(BUILD_DIR)/hardware/src
BUILD_EMB_DIR = $(BUILD_DIR)/software/embedded
BUILD_PC_DIR = $(BUILD_DIR)/software/pc-emul
BUILD_SIM_DIR = $(BUILD_DIR)/hardware/simulation
BUILD_FPGA_DIR = $(BUILD_DIR)/hardware/fpga
BUILD_LINT_DIR = $(BUILD_DIR)/hardware/lint/spyglass

BUILD_ESRC_DIR = $(BUILD_DIR)/software/esrc
BUILD_PSRC_DIR = $(BUILD_DIR)/software/psrc
BUILD_DOC_DIR = $(BUILD_DIR)/document
BUILD_FIG_DIR = $(BUILD_DOC_DIR)/figures
BUILD_TSRC_DIR = $(BUILD_DOC_DIR)/tsrc
BUILD_SW_PYTHON_DIR = $(BUILD_DIR)/scripts


setup: debug
	./$(NAME)_setup.py

$(BUILD_DIR):
	@rsync -avz --exclude .git --exclude submodules --exclude .gitmodules --exclude .github  . $@
	echo "NAME=$(NAME)" > $@/info.mk
	echo "VERSION=$(VERSION)" >> $@/info.mk
	echo "BUILD_DIR_NAME=$(BUILD_DIR_NAME)" >> $@/info.mk
	echo "FLOWS=$(FLOWS)" >> $@/info.mk
	find $@ -name \*_setup.mk -delete
	cp $(LIB_DIR)/build.mk $@/Makefile

#
#HARDWARE
#

# include local setup makefile segment
ifneq ($(wildcard hardware/hw_setup.mk),)
include hardware/hw_setup.mk
endif

SRC+=$(BUILD_VSRC_DIR)/$(NAME)_version.vh
$(BUILD_VSRC_DIR)/$(NAME)_version.vh: config_setup.mk
	$(LIB_DIR)/scripts/version.py -v . -o $(@D)

#simulation
ifneq ($(wildcard hardware/simulation),)

#include local simulation makefile segment
ifneq ($(wildcard hardware/simulation/sim_setup.mk),)
include hardware/simulation/sim_setup.mk
endif

#copy simulation files from LIB 
SRC+=$(patsubst $(LIB_DIR)/hardware/simulation/%, $(BUILD_SIM_DIR)/%, $(wildcard $(LIB_DIR)/hardware/simulation/*))
$(BUILD_SIM_DIR)/%: $(LIB_DIR)/hardware/simulation/%
	cp -r $< $@
endif

#fpga
ifneq ($(wildcard hardware/fpga),)

#include local fpga makefile segment
ifneq ($(wildcard hardware/fpga/fpga_setup.mk),)
include hardware/fpga/fpga_setup.mk
endif

#copy quartus files from LIB
ifneq ($(wildcard hardware/fpga/quartus),)
SRC+=$(patsubst $(LIB_DIR)/hardware/fpga/quartus/%, $(BUILD_FPGA_DIR)/quartus/%, $(wildcard $(LIB_DIR)/hardware/fpga/quartus/*))
$(BUILD_FPGA_DIR)/quartus/%: $(LIB_DIR)/hardware/fpga/quartus/%
	cp -r $< $@
endif

#copy vivado files from LIB
ifneq ($(wildcard hardware/fpga/vivado),)
SRC+=$(patsubst $(LIB_DIR)/hardware/fpga/vivado/%, $(BUILD_FPGA_DIR)/vivado/%, $(wildcard $(LIB_DIR)/hardware/fpga/vivado/*))
$(BUILD_FPGA_DIR)/vivado/%: $(LIB_DIR)/hardware/fpga/vivado/%
	cp -r $< $@
endif

#copy fpga makefile
SRC+=$(BUILD_FPGA_DIR)/Makefile
$(BUILD_FPGA_DIR)/Makefile: $(LIB_DIR)/hardware/fpga/Makefile
	cp $< $@

endif

#synthesis
ifneq ($(wildcard hardware/synthesis),)

#include  local asic synthesis makefile segment
ifneq ($(wildcard hardware/syn/syn_setup.mk),)
include hardware/syn/syn_setup.mk
endif

#copy asic synthesis files from LIB
SRC+=$(patsubst $(LIB_DIR)/hardware/syn/%, $(BUILD_FPGA_DIR)/%, $(wildcard $(LIB_DIR)/hardware/syn/*))
$(BUILD_SYN_DIR)/%: $(LIB_DIR)/hardware/syn/%
	cp $< $@

endif

#lint
#copy lint files from LIB 
ifneq ($(wildcard hardware/lint/spyglass),)
SRC+=$(patsubst $(LIB_DIR)/hardware/lint/spyglass/%, $(BUILD_LINT_DIR)/%, $(wildcard $(LIB_DIR)/hardware/lint/spyglass/*))
$(BUILD_LINT_DIR)/%: $(LIB_DIR)/hardware/lint/spyglass/%
	sed 's/IOB_CORE_NAME/$(NAME)/g' $< > $@

endif

#
#SOFTWARE
#

ifneq ($(wildcard software),)

#include software makefile segment
ifneq ($(wildcard software/sw_setup.mk),)
include software/sw_setup.mk
endif

#copy source files from LIB 
SRC+=$(patsubst $(LIB_DIR)/software/src/%, $(BUILD_ESRC_DIR)/%, $(wildcard $(LIB_DIR)/software/src/%))
$(BUILD_ESRC_DIR)/%: $(LIB_DIR)/software/src/%
	cp $< $@

#copy embedded files from LIB
ifneq ($(wildcard software/embedded),)
SRC+=$(patsubst $(LIB_DIR)/software/embedded/%, $(BUILD_EMB_DIR)/%, $(wildcard $(LIB_DIR)/software/embedded/*))
$(BUILD_EMB_DIR)/%: $(LIB_DIR)/software/embedded/%
	cp $< $@
endif

#copy pc-emul files from LIB
ifneq ($(wildcard software/pc-emul),)
SRC+=$(patsubst $(LIB_DIR)/software/pc-emul/%, $(BUILD_PC_DIR)/%, $(wildcard $(LIB_DIR)/software/pc-emul/*))
$(BUILD_PC_DIR)/%: $(LIB_DIR)/software/pc-emul/%
	cp $< $@
endif

endif

#
#DOCUMENT
#

ifneq ($(wildcard document),)

#include local fpga makefile segment
ifneq ($(wildcard document/doc_setup.mk),)
include document/doc_setup.mk
endif

#make and install core version file
SRC+=$(BUILD_TSRC_DIR)/$(NAME)_version.tex
$(BUILD_TSRC_DIR)/$(NAME)_version.tex:
	$(LIB_DIR)/scripts/version.py -t .
	mv $(NAME)_version.tex $(BUILD_TSRC_DIR)

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
	@rm -rf $(BUILD_DIR) *.tex *.v *.vh *.h
	@rm -rf scripts/__pycache__

debug: $(BUILD_DIR) $(SRC)
	@echo SRC=$(SRC)


.PHONY: setup debug

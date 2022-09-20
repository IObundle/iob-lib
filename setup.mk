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

# establish build dir paths
BUILD_DIR := ../$(NAME)_$(VERSION_STR)

BUILD_VSRC_DIR = $(BUILD_DIR)/hardware/src
BUILD_SIM_DIR = $(BUILD_DIR)/hardware/simulation
BUILD_FPGA_DIR = $(BUILD_DIR)/hardware/fpga

BUILD_ESRC_DIR = $(BUILD_DIR)/software/esrc
BUILD_PSRC_DIR = $(BUILD_DIR)/software/esrc
BUILD_DOC_DIR = $(BUILD_DIR)/document
BUILD_FIG_DIR = $(BUILD_DOC_DIR)/figures
BUILD_TSRC_DIR = $(BUILD_DOC_DIR)/tsrc


setup: debug

$(BUILD_DIR):
	@rsync -avz --exclude .git --exclude submodules --exclude .gitmodules --exclude .github  . $@
	echo "NAME=$(NAME)" > $@/info.mk
	echo "VERSION=$(VERSION)" >> $@/info.mk
	find $@ -name \*_setup.mk -delete
	cp $(LIB_DIR)/build.mk $@/Makefile

#
#HARDWARE
#

ifneq ($(wildcard hardware/hw_setup.mk),)
include hardware/hw_setup.mk
endif

SRC+=$(BUILD_VSRC_DIR)/$(NAME)_version.vh
$(BUILD_VSRC_DIR)/$(NAME)_version.vh: config_setup.mk
	$(LIB_DIR)/scripts/version.py -v .
	mv $(NAME)_version.vh $(BUILD_VSRC_DIR)

# select core configuration
SRC+=$(BUILD_VSRC_DIR)/$(NAME)_conf.vh
$(BUILD_VSRC_DIR)/$(NAME)_conf.vh: hardware/src/$(NAME)_conf_$(CONFIG).vh
	cp hardware/src/$(NAME)_conf_$(CONFIG).vh $@

# header files
define copy_verilog_headers
SRC+=$(patsubst $(1)/hardware/src/%.vh, $(BUILD_VSRC_DIR)/%.vh, $(wildcard $(1)/hardware/src/*.vh))

$(BUILD_VSRC_DIR)/%.vh: $(1)/hardware/src/%.vh
	cp $< $@
endef

# source files
define copy_verilog_sources
SRC+=$(patsubst $(1)/hardware/src/%, $(BUILD_VSRC_DIR)/%, $(wildcard $(1)/hardware/src/*))
$(BUILD_VSRC_DIR)/%: $(1)/hardware/src/%
	cp $< $@
endef



#simulation
ifneq ($(wildcard hardware/simulation),)

ifneq ($(wildcard hardware/simulation/sim_setup.mk),)
include hardware/simulation/sim_setup.mk
endif

SRC+=$(patsubst $(LIB_DIR)/hardware/simulation/%, $(BUILD_SIM_DIR)/%, $(wildcard $(LIB_DIR)/hardware/simulation/*))
$(BUILD_SIM_DIR)/%: $(LIB_DIR)/hardware/simulation/%
	cp $< $@
endif

#fpga
ifneq ($(wildcard hardware/fpga),)

ifneq ($(wildcard hardware/fpga/fpga_setup.mk),)
include hardware/fpga/fpga_setup.mk
endif

SRC+=$(patsubst $(LIB_DIR)/hardware/fpga/%, $(BUILD_FPGA_DIR)/%, $(wildcard $(LIB_DIR)/hardware/fpga/*))
$(BUILD_FPGA_DIR)/%: $(LIB_DIR)/hardware/fpga/%
	cp -r $< $@

endif

#synthesis
ifneq ($(wildcard hardware/synthesis),)

ifneq ($(wildcard hardware/syn/syn_setup.mk),)
include hardware/syn/syn_setup.mk
endif

SRC+=$(patsubst $(LIB_DIR)/hardware/syn/%, $(BUILD_FPGA_DIR)/%, $(wildcard $(LIB_DIR)/hardware/syn/*))
$(BUILD_SYN_DIR)/%: $(LIB_DIR)/hardware/syn/%
	cp $< $@

endif


#
#SOFTWARE
#

ifneq ($(wildcard software),)

ifneq ($(wildcard software/sw_setup.mk),)
include software/sw_setup.mk
endif

SRC+=$(patsubst $(LIB_DIR)/software/src/%, $(BUILD_ESRC_DIR)/%, $(wildcard $(LIB_DIR)/software/src/%))
$(BUILD_ESRC_DIR)/%: $(LIB_DIR)/software/src/%
	cp $< $@

endif

#
#DOCUMENT
#

ifneq ($(wildcard document),)

# include local setup stub
ifneq ($(wildcard document/doc_setup.mk),)
include document/doc_setup.mk
endif

# core version file
SRC+=$(BUILD_TSRC_DIR)/$(NAME)_version.tex
$(BUILD_TSRC_DIR)/$(NAME)_version.tex:
	$(LIB_DIR)/scripts/version.py -t .
	mv iob_cache_version.tex $(BUILD_TSRC_DIR)

# short git hash file
SRC+=$(BUILD_TSRC_DIR)/shortHash.tex
$(BUILD_TSRC_DIR)/shortHash.tex:
	git rev-parse --short HEAD > $@


#generate tex files from code comments
ifneq ($(wildcard mkregs.conf),)
MKREGS_CONF:=mkregs.conf
endif

#copy lib tex files if not present
SRC+=$(patsubst $(LIB_DIR)/document/tsrc/%, $(BUILD_TSRC_DIR)/%, $(wildcard $(LIB_DIR)/document/tsrc/*))
$(BUILD_TSRC_DIR)/%: $(LIB_DIR)/document/tsrc/%
	if [ ! -f $@ ]; then cp $< $@; fi

#copy figures
SRC+=$(patsubst $(LIB_DIR)/document/figures/%, $(BUILD_FIG_DIR)/%, $(wildcard $(LIB_DIR)/document/figures/*))
$(BUILD_FIG_DIR)/%: $(LIB_DIR)/document/figures/%
	cp $< $@

SRC+=$(BUILD_DOC_DIR)/Makefile
$(BUILD_DOC_DIR)/Makefile: $(LIB_DIR)/document/Makefile
	cp $< $@

v2tex: $(SRC)
ifeq ($(wildcard *.tex),)
	$(PYTHON_DIR)/verilog2tex.py hardware/src/$(NAME).v hardware/src/* $(LIB_DIR)/hardware/include/*.vh *.vh $(MKREGS_CONF)
	cp *.tex $(BUILD_DOC_DIR)
endif

endif


clean:
	@rm -rf $(BUILD_DIR) *.tex *.v *.vh
	@rm -rf scripts/__pycache__

debug: $(BUILD_DIR) $(SRC) v2tex
	@echo SRC=$(SRC)


.PHONY: setup debug v2tex

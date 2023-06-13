# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This file is run as a makefile to setup a build directory for an IP core
#

SHELL=bash


help:
	@echo The following targets are available:
	@echo "  setup:  Setup the build directory"
	@echo "  clean:  Remove the build directory"
	@echo "  debug:  Print all source files in the build directory"



TOP_MODULE_NAME ?=$(basename $(wildcard *.py))
PROJECT_ROOT ?=.

LIB_DIR ?=submodules/LIB
SETUP_ARGS += LIB_DIR=$(LIB_DIR)

# python scripts directory
PYTHON_DIR=$(LIB_DIR)/scripts

PYTHON_EXEC:=/usr/bin/env python3 -B

#submodule directories DEPRECATED
#$(foreach entry, $(shell $(PYTHON_EXEC) $(PYTHON_DIR)/setup.py get_core_submodules_dirs), $(eval $(entry)))

# establish build dir paths
BUILD_DIR := $(shell $(PYTHON_EXEC) $(PYTHON_DIR)/bootstrap.py $(TOP_MODULE_NAME) $(SETUP_ARGS) -f get_build_dir -s $(PROJECT_ROOT))

BUILD_VSRC_DIR = $(BUILD_DIR)/hardware/src

BUILD_SIM_DIR := $(BUILD_DIR)/hardware/simulation

BUILD_FPGA_DIR = $(BUILD_DIR)/hardware/fpga
BUILD_SYN_DIR = $(BUILD_DIR)/hardware/syn

BUILD_DOC_DIR = $(BUILD_DIR)/document
BUILD_FIG_DIR = $(BUILD_DOC_DIR)/figures
BUILD_TSRC_DIR = $(BUILD_DOC_DIR)/tsrc

python-format:
	$(LIB_DIR)/scripts/black_format.py

python-format-check:
	$(LIB_DIR)/scripts/black_format.py --check

c-format:
	$(LIB_DIR)/scripts/clang_format.py

c-format-check:
	$(LIB_DIR)/scripts/clang_format.py --check

IOB_LIB_PATH=$(LIB_DIR)/scripts
export IOB_LIB_PATH

# Auto-disable linter and formatter if setting up with the Tester
ifeq ($(TESTER),1)
	DISABLE_LINT:=1
	DISABLE_FORMAT:=1
endif

verilog-lint:
ifneq ($(DISABLE_LINT),1)
	# Run linter on all verilog files of setup directory
	$(IOB_LIB_PATH)/verilog-lint.sh `find hardware -type f -name "*.v?" -o -name "*.v" | tr '\n' ' '`
	# Run linter on all verilog files of build directory (includes generated files)
	$(IOB_LIB_PATH)/verilog-lint.sh `find $(BUILD_DIR) -type f -not -path "*version.vh" -not -path "*test_*.vh" -name "*.v?" -o -name "*.v"  | tr '\n' ' '`
endif
verilog-format:
ifneq ($(DISABLE_FORMAT),1)
	# Run formatter on all verilog files of setup directory
	$(IOB_LIB_PATH)/verilog-format.sh `find  hardware -type f -name "*.v?" -o -name "*.v" | tr '\n' ' '`
	# Run formatter on all verilog files of build directory (includes generated files)
	$(IOB_LIB_PATH)/verilog-format.sh `find $(BUILD_DIR) -type f -not -path "*test_*.vh" -name "*.v?" -o -name "*.v" | tr '\n' ' '`
endif

format-check-all: $(BUILD_DIR) python-format-check c-format-check verilog-lint verilog-format

setup: debug

$(BUILD_DIR):
	$(PYTHON_EXEC) ./$(PYTHON_DIR)/bootstrap.py $(TOP_MODULE_NAME) $(SETUP_ARGS) -s $(PROJECT_ROOT)

#
#DOCUMENT
#

ifneq ($(wildcard document),)

ifeq ($(INTEL_FPGA),1)
SRC+=$(BUILD_DIR)/doc/quartus.tex
endif

ifeq ($(AMD_FPGA),1)
SRC+=$(BUILD_DIR)/doc/vivado.tex
endif

# generate quartus fitting results 
$(BUILD_DIR)/doc/quartus.tex:
	make -C $(BUILD_DIR) fpga-build BOARD=CYCLONEV-GT-DK
	LOG=$(BUILD_FPGA_DIR)/reports/$(wildcard *.fit.summary) $(LIB_DIR)/scripts/quartus2tex.sh
	mv `basename $@` $(BUILD_DOC_DIR)

# generate vivado fitting results 
$(BUILD_DIR)/doc/vivado.tex:
	make -C $(BUILD_DIR) fpga-build BOARD=AES-KU040-DB-G
	LOG=$(BUILD_FPGA_DIR)/vivado.log $(LIB_DIR)/scripts/vivado2tex.sh
	mv `basename $@` $(BUILD_DOC_DIR)

endif

clean:
	-@if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
ifneq ($(wildcard config_delivery.mk),)
	make delivery-clean
endif

# Remove all __pycache__ folders with python bytecode
python-cache-clean:
	find . -name "*__pycache__" -exec rm -rf {} \; -prune

debug: format-check-all $(BUILD_DIR) $(SRC)
	@for i in $(SRC); do echo $$i; done


.PHONY: setup clean debug python-format-check verilog-format-check verilog-format

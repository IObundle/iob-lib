# Copyright © 2023 IObundle, Lda. All rights reserved.
#
# This file is copied to the root of the build directory and becomes the top Makefile.
#

include config_build.mk

BSP_H ?= software/bsp.h
SIM_DIR = hardware/simulation
BOARD_DIR = $(shell find -name $(BOARD) -type d -print -quit)

#
# Create bsp.h from bsp.vh
#
$(BSP_H):
	if [[ $(MAKECMDGOALS) == *fpga* ]]; then \
		cp $(BOARD_DIR)/bsp.vh $(BSP_H); \
	else \
		cp $(SIM_DIR)/bsp.vh $(BSP_H); \
	fi; sed -i 's/`/#/g' $(BSP_H);

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  fw-build          to build the firmware"
	@echo "  fw-clean          to clean the firmware"
	@echo "  pc-emul           to build the emulator for PC"
	@echo "  pc-emul-clean     to clean the emulator for PC"
	@echo "  pc-emul-run       to run the emulator for PC"
	@echo "  lint-run          to run the linter"
	@echo "  lint-clean        to clean the linter"
	@echo "  lint-test	   to run the linter test"
	@echo "  sim-build         to build the RTL simulator"
	@echo "  sim-clean         to clean the RTL simulator"
	@echo "  sim-run           to run the RTL simulator"
	@echo "  sim-test          to run the RTL simulator test"
	@echo "  sim-waves	   to run the RTL simulator with waves"
	@echo "  sim-debug         to print important simulation Makefile variables"
	@echo "  cov-test          to run the RTL simulator test with coverage"
	@echo "  fpga-fw-build     to build the firmware for FPGA targets"
	@echo "  fpga-build        to build the FPGA netlist or bitstream"
	@echo "  fpga-clean        to clean the FPGA netlist or bitstream"
	@echo "  fpga-run          to run the FPGA bitstream"
	@echo "  fpga-test         to run the FPGA bitstream test"
	@echo "  fpga-debug        to print important FPGA Makefile variables"
	@echo "  syn-build         to synthetize the design for ASIC targets"
	@echo "  syn-clean         to clean the synthetize the design for ASIC targets"
	@echo "  doc-build         to build the documentation"
	@echo "  doc-clean         to clean the documentation"
	@echo "  doc-view	   to view the documentation"
	@echo "  doc-test          to run the RTL simulator test"
	@echo "  test 		   to run all tests"
	@echo "  ptest 		   to run all production tests"
	@echo "  dtest 		   to run all delivery tests"
	@echo "  debug             to print important Makefile variables"
	@echo "  clean             to clean all the build files"



# 
# EMBEDDED SOFTWARE
#
ifneq ($(filter emb, $(FLOWS)),)
SW_DIR=software
fw-build: $(BSP_H)
	make -C $(SW_DIR) build

fw-clean:
	make -C $(SW_DIR) clean
endif

fpga-fw-build: fw-build

#
# PC EMUL
#
ifneq ($(filter pc-emul, $(FLOWS)),)
pc-emul-build: fw-build
	make -C $(SW_DIR) build_emul

pc-emul-run: $(BSP_H)
	make -C $(SW_DIR) run_emul

pc-emul-test: $(BSP_H)
	make -C $(SW_DIR) test_emul

pc-emul-clean:
	make -C $(SW_DIR) clean
endif


#
# LINT
#

ifneq ($(filter lint, $(FLOWS)),)
LINTER ?= spyglass
LINT_DIR=hardware/lint
lint-run:
	make -C $(LINT_DIR) run

lint-clean:
	make -C $(LINT_DIR) clean

lint-test:
	make lint-run LINTER=spyglass
	make lint-run LINTER=alint
endif


#
# SIMULATE
#
ifneq ($(filter sim, $(FLOWS)),)
sim-build: fw-build
	make -C $(SIM_DIR) build

sim-run: fw-build
	make -C $(SIM_DIR) run

sim-waves:
	make -C $(SIM_DIR) waves

sim-debug: 
	make -C $(SIM_DIR) debug

sim-clean:
	make -C $(SIM_DIR) clean

sim-test: fw-build
	make -C $(SIM_DIR) test

cov-test: sim-clean
	make -C $(SIM_DIR) test COV=1

endif


#
# FPGA
#
ifneq ($(filter fpga, $(FLOWS)),)
FPGA_DIR=hardware/fpga
fpga-build:
	make -C $(FPGA_DIR) build

fpga-run:
	make -C $(FPGA_DIR) run

fpga-test:
	make -C $(FPGA_DIR) test

fpga-debug:
	echo "BOARD=$(BOARD)"
	make -C $(FPGA_DIR) debug

fpga-clean:
	make -C $(FPGA_DIR) clean
endif

#
# SYN
#
ifneq ($(filter syn, $(FLOWS)),)
SYN_DIR=hardware/syn
syn-build:
	make -C $(SYN_DIR) build

syn-clean:
	make -C $(SYN_DIR) clean
endif

syn-test: syn-clean syn-build

#
# DOCUMENT
#
ifneq ($(filter doc, $(FLOWS)),)
DOC_DIR=document
doc-build: $(BSP_H)
	make -C $(DOC_DIR) build

doc-view: $(BSP_H)
	make -C $(DOC_DIR) view

doc-debug: 
	make -C $(DOC_DIR) debug

doc-clean:
ifneq ($(wildcard $(DOC_DIR)/Makefile),)
	make -C $(DOC_DIR) clean
endif

ifneq ($(wildcard document/tsrc),)
doc-test: doc-clean
	make -C $(DOC_DIR) test
else
doc-test:
endif

endif

#
# TEST
#
test: sim-test fpga-test doc-test

ptest: test syn-test lint-test cov-test

dtest: sim-test syn-test fpga-test

#
# DEBUG
#
debug:
	@echo $(FLOWS)



#
# CLEAN
#

clean: fw-clean pc-emul-clean lint-clean sim-clean fpga-clean doc-clean
	rm -f $(BSP_H)


.PHONY: fw-build fpga-fw-build \
	pc-emul-build pc-emul-run \
	lint-test lint-run lint-clean \
	sim-build sim-run sim-debug \
	fpga-build fpga-debug \
	doc-build doc-view doc-debug \
	test clean debug \
	sim-test fpga-test doc-test \
	fw-clean pc-emul-clean sim-clean fpga-clean doc-clean

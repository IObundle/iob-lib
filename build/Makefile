SHELL:=/bin/bash
export

include info.mk
include version.mk

#
# SIMULATE
#

SIM_DIR=hw/sim
sim-build: 
	make -C $(SIM_DIR) build

sim-run: sim-build
	make -C $(SIM_DIR) run

sim-test: 
	make -C $(SIM_DIR) test

sim-clean: 
	make -C $(SIM_DIR) clean

sim-debug: 
	make -C $(SIM_DIR) debug

#
# FPGA
#

FPGA_DIR=hw/fpga
fpga-build: 
	make -C $(FPGA_DIR) build

fpga-run: 
	make -C $(FPGA_DIR) run

fpga-test: 
	make -C $(FPGA_DIR) test

fpga-clean: 
	make -C $(FPGA_DIR) clean

fpga-debug: 
	make -C $(FPGA_DIR) debug

#
# DOCUMENT
#
DOC_DIR=doc
doc-build: 
	make -C $(DOC_DIR) build

doc-test: 
	make -C $(DOC_DIR) test

doc-clean: 
	make -C $(DOC_DIR) clean

doc-debug: 
	make -C $(DOC_DIR) debug

#
# PREPROCESS
#
PPROC_DIR=pproc
pproc-build:
	make -C $(PPROC_DIR)/hw build

pproc-clean:
	make -C $(PPROC_DIR)/hw clean

#
# TEST
#

test: build-clean sim-test fpga-test doc-test


#
# CLEAN
#

clean: sim-clean fpga-clean doc-clean


.PHONY:	sim-build sim-run sim-test sim-debug sim-clean \
	fpga-build fpga-test fpga-clean fpga-debug \
	doc-build doc-test doc-clean doc-debug \
	test clean

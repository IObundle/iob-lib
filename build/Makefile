SHELL:=/bin/bash
export

# 
# EMBEDDED SOFTWARE
#
EMB_DIR=sw/emb

fw-clean:
ifneq ($(wildcard $(EMB_DIR)/.),)
	make -C $(EMB_DIR) clean-all

fw-build:
	make -C $(EMB_DIR) build-all
endif

#
# PC EMUL
#
PC_DIR=sw/pc

pc-emul-clean:
ifneq ($(wildcard $(PC_DIR)/.),)
	make -C $(PC_DIR) clean

pc-emul-build: fw-build
	make -C $(PC_DIR) build

pc-emul-run:
	make -C $(PC_DIR) run

pc-emul-test:
	make -C $(PC_DIR) test
endif

#
# SIMULATE
#
SIM_DIR=hw/sim

sim-clean:
ifneq ($(wildcard $(SIM_DIR)/.),)
	make -C $(SIM_DIR) clean

sim-build: 
	make -C $(SIM_DIR) build

sim-run: sim-build
	make -C $(SIM_DIR) run

sim-test: 
	make -C $(SIM_DIR) test

sim-debug: 
	make -C $(SIM_DIR) debug
endif


#
# FPGA
#
FPGA_DIR=hw/fpga

fpga-clean:
ifneq ($(wildcard $(FPGA_DIR)/.),)
	make -C $(FPGA_DIR) clean

fpga-build: 
	make -C $(FPGA_DIR) build

fpga-run: 
	make -C $(FPGA_DIR) run

fpga-test: 
	make -C $(FPGA_DIR) test

fpga-debug: 
	make -C $(FPGA_DIR) debug
endif


#
# DOCUMENT
#
DOC_DIR=doc

doc-clean:
ifneq ($(wildcard $(DOC_DIR)/.),)
	make -C $(DOC_DIR) clean

doc-build: 
	make -C $(DOC_DIR) build

doc-test: 
	make -C $(DOC_DIR) test

doc-debug: 
	make -C $(DOC_DIR) debug
endif

#
# TEST
#
TEST_TYPE_LIST=sim-test
TEST_TYPE_LIST=fpga-test
TEST_TYPE_LIST=doc-test

test: $(TEST_TYPE_LIST)


#
# CLEAN
#

clean: fw-clean pc-emul-clean sim-clean fpga-clean doc-clean


.PHONY:	sim-build sim-run sim-test sim-debug sim-clean \
	fpga-build fpga-test fpga-clean fpga-debug \
	doc-build doc-test doc-clean doc-debug \
	test clean

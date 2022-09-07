SHELL:=/bin/bash
export
unexport CLEAN_LIST

# 
# EMBEDDED SOFTWARE
#
EMB_DIR=sw/emb
ifneq ($(wildcard $(EMB_DIR)/.),)
fw-build:
	make -C $(EMB_DIR) build-all

CLEAN_LIST+=fw-clean
fw-clean:
	make -C $(EMB_DIR) clean-all
endif

#
# PC EMUL
#
PC_DIR=sw/pc
ifneq ($(wildcard $(PC_DIR)/.),)
pc-emul-build: fw-build
	make -C $(PC_DIR) build

pc-emul-run:
	make -C $(PC_DIR) run

pc-emul-test:
	make -C $(PC_DIR) test

CLEAN_LIST+=pc-emul-clean
pc-emul-clean:
	make -C $(PC_DIR) clean
endif

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

sim-debug: 
	make -C $(SIM_DIR) debug

CLEAN_LIST+=sim-clean
sim-clean:
	make -C $(SIM_DIR) clean


#
# FPGA
#
FPGA_DIR=hw/fpga
ifneq ($(wildcard $(FPGA_DIR)/.),)
fpga-build: 
	make -C $(FPGA_DIR) build

fpga-run: 
	make -C $(FPGA_DIR) run

fpga-test: 
	make -C $(FPGA_DIR) test

fpga-debug: 
	make -C $(FPGA_DIR) debug

CLEAN_LIST+=fpga-clean
fpga-clean:
	make -C $(FPGA_DIR) clean
endif


#
# DOCUMENT
#
DOC_DIR=doc
ifneq ($(wildcard $(DOC_DIR)/.),)
doc-build: 
	make -C $(DOC_DIR) build

doc-test: 
	make -C $(DOC_DIR) test

doc-debug: 
	make -C $(DOC_DIR) debug

CLEAN_LIST+=doc-clean
doc-clean:
	make -C $(DOC_DIR) clean
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

clean: $(CLEAN_LIST)


.PHONY: fw-build fw-clean \
	pc-emul-build pc-emul-run pc-emul-test pc-emul-clean \
	sim-build sim-run sim-test sim-debug sim-clean \
	fpga-build fpga-test fpga-clean fpga-debug \
	doc-build doc-test doc-clean doc-debug \
	test clean

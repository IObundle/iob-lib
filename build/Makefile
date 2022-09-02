SHELL:=/bin/bash
export

include config_setup.mk


# 
# EMBEDDED SOFTWARE
#
EMB_DIR=sw/emb
ifeq ($(SETUP_SW),1)
fw-build:
	make -C $(EMB_DIR) build-all
endif

fw-clean:
	make -C $(EMB_DIR) clean-all

#
# PC EMUL
#
PC_DIR=sw/pc
ifeq ($(SETUP_SW),1)
pc-emul-build: fw-build
	make -C $(PC_DIR) build

pc-emul-run:
	make -C $(PC_DIR) run

pc-emul-test:
	make -C $(PC_DIR) test
endif

pc-emul-clean:
	make -C $(PC_DIR) clean


#
# SIMULATE
#
SIM_DIR=hw/sim
ifeq ($(SETUP_SIM),1)
sim-build: 
	make -C $(SIM_DIR) build

sim-run: sim-build
	make -C $(SIM_DIR) run

sim-test: 
	make -C $(SIM_DIR) test

sim-debug: 
	make -C $(SIM_DIR) debug
endif

sim-clean: 
	make -C $(SIM_DIR) clean


#
# FPGA
#
FPGA_DIR=hw/fpga
ifeq ($(SETUP_FPGA),1)
fpga-build: 
	make -C $(FPGA_DIR) build

fpga-run: 
	make -C $(FPGA_DIR) run

fpga-test: 
	make -C $(FPGA_DIR) test

fpga-debug: 
	make -C $(FPGA_DIR) debug
endif

fpga-clean: 
	make -C $(FPGA_DIR) clean


#
# DOCUMENT
#
DOC_DIR=doc
ifeq ($(SETUP_DOC),1)
doc-build: 
	make -C $(DOC_DIR) build

doc-test: 
	make -C $(DOC_DIR) test

doc-debug: 
	make -C $(DOC_DIR) debug
endif

doc-clean: 
	make -C $(DOC_DIR) clean

#
# TEST
#
ifeq ($(SETUP_SIM),1)
TEST_TYPE_LIST=sim-test
endif
ifeq ($(SETUP_FPGA),1)
TEST_TYPE_LIST=fpga-test
endif
ifeq ($(SETUP_DOC),1)
TEST_TYPE_LIST=doc-test
endif

test: $(TEST_TYPE_LIST)


#
# CLEAN
#

clean: fw-clean pc-emul-clean sim-clean fpga-clean doc-clean
	@rm -f ../*.v ../*.vh ../*.c ../*.h


.PHONY:	sim-build sim-run sim-test sim-debug sim-clean \
	fpga-build fpga-test fpga-clean fpga-debug \
	doc-build doc-test doc-clean doc-debug \
	test clean

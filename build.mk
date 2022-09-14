SHELL:=/bin/bash
export

# 
# EMBEDDED SOFTWARE
#
EMB_DIR=software/emb
ifneq ($(wildcard $(EMB_DIR)),)
fw-build:
	make -C $(EMB_DIR) build-all

fw-clean:
	make -C $(EMB_DIR) clean-all
endif

#
# PC EMUL
#
PC_DIR=software/pc
ifneq ($(wildcard $(PC_DIR)),)
pc-emul-build: fw-build
	make -C $(PC_DIR) build

pc-emul-run:
	make -C $(PC_DIR) run

pc-emul-test:
	make -C $(PC_DIR) test

pc-emul-clean:
	make -C $(PC_DIR) clean
endif

#
# SIMULATE
#
SIM_DIR=hardware/simulation
sim-build: 
	make -C $(SIM_DIR) build

sim-run: sim-build
	make -C $(SIM_DIR) run

sim-test: 
	make -C $(SIM_DIR) test

sim-debug: 
	make -C $(SIM_DIR) debug

sim-clean:
	make -C $(SIM_DIR) clean


#
# FPGA
#
FPGA_DIR=hardware/fpga
BOARD ?= CYCLONEV-GT-DK
ifneq ($(wildcard $(FPGA_DIR)),)
fpga-build: 
	make -C $(FPGA_DIR) build

fpga-run: 
	make -C $(FPGA_DIR) run

fpga-test: 
	make -C $(FPGA_DIR) test

fpga-debug: 
	make -C $(FPGA_DIR) debug

fpga-clean:
	make -C $(FPGA_DIR) clean
endif


#
# DOCUMENT
#
DOC_DIR=document
ifneq ($(wildcard $(DOC_DIR)),)
doc-build: 
	make -C $(DOC_DIR) build

doc-test: 
	make -C $(DOC_DIR) test

doc-debug: 
	make -C $(DOC_DIR) debug

doc-clean:
	make -C $(DOC_DIR) clean
endif

#
# TEST
#
test: sim-test fpga-test doc-tes



#
# CLEAN
#

clean: fw-clean pc-emul-clean sim-clean fpga-clean doc-clean


.PHONY: fw-build \
	pc-emul-build pc-emul-run \
	sim-build sim-run sim-debug \
	fpga-build fpga-debug \
	doc-build doc-debug \
	test clean \
	sim-test fpga-test doc-test \
	fw-clean pc-emul-clean sim-clean fpga-clean doc-clean

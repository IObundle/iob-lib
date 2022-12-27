SHELL:=bash
export

include config_build.mk

# 
# EMBEDDED SOFTWARE
#
ifneq ($(filter emb, $(FLOWS)),)
EMB_DIR=software/embedded
fw-build:
	make -C $(EMB_DIR) build

fw-clean:
	make -C $(EMB_DIR) clean
endif

#
# PC EMUL
#
ifneq ($(filter pc-emul, $(FLOWS)),)
PC_DIR=software/pc-emul
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
# LINTER
#
ifneq ($(filter lint, $(FLOWS)),)
LINT_DIR=hardware/lint
lint-run:
	make -C $(LINT_DIR) run

lint-clean:
	make -C $(LINT_DIR) clean
endif

ifneq ($(wildcard hardware/lint),)
lint-test: spyglass-test #alint-test

spyglass-test:
	make lint-run LINTER=spyglass

alint-test:
	make lint-run LINTER=alint
else
lint-test:
endif




#
# SIMULATE
#
ifneq ($(filter sim, $(FLOWS)),)
SIM_DIR=hardware/simulation
sim-build: 
	make -C $(SIM_DIR) build

sim-run:
	make -C $(SIM_DIR) run

sim-waves:
	make -C $(SIM_DIR) waves

sim-test: 
	make -C $(SIM_DIR) test

sim-debug: 
	make -C $(SIM_DIR) debug

sim-clean:
	make -C $(SIM_DIR) clean
endif

cov-test: sim-clean
	make -C $(SIM_DIR) test COV=1


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
doc-build: 
	make -C $(DOC_DIR) build

doc-debug: 
	make -C $(DOC_DIR) debug

doc-clean:
	make -C $(DOC_DIR) clean


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

#
# DEBUG
#
debug:
	@echo $(FLOWS)

#
# CLEAN
#

clean: fw-clean pc-emul-clean lint-clean sim-clean fpga-clean doc-clean


.PHONY: fw-build \
	pc-emul-build pc-emul-run \
	spyglass-run spyglass-clean \
	alint-run alint-clean \
	lint-test lint-clean \
	sim-build sim-run sim-debug \
	fpga-build fpga-debug \
	doc-build doc-debug \
	test clean debug \
	sim-test fpga-test doc-test \
	fw-clean pc-emul-clean sim-clean fpga-clean doc-clean

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#

SHELL=bash
export

#build here
LIB_DIR:=.
BUILD_VSRC_DIR:=./hardware/src
BUILD_SIM_DIR:=.
REMOTE_BUILD_DIR:=$(USER)/iob-lib
REMOTE_SRC_DIR:=$(REMOTE_BUILD_DIR)/hardware/src

LINT_SERVER=$(SYNOPSYS_SERVER)
LINT_USER=$(SYNOPSYS_USER)
LINT_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
LINT_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
LINT_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)

PYTHON_EXEC:=/usr/bin/env python3 -B

all: sim

# Default module
MODULE ?= iob_ram_2p
MODULE_DIR ?= $(shell find hardware -name $(MODULE))
ifeq ($(MODULE_DIR),)
$(info No such module $(MODULE))
endif

# Defines
DEFINE=-DADDR_W=10 -DDATA_W=32

VCD?=0
ifeq ($(VCD),1)
DEFINE+= -DVCD
endif

# Includes
INCLUDE=-Ihardware/modules

# asymmetric memory present
IS_ASYM ?= 0

#
# Simulate with Icarus Verilog
#
VLOG=iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

$(BUILD_VSRC_DIR):
	@mkdir $@

copy_srcs: $(BUILD_VSRC_DIR) 
	$(PYTHON_EXEC) ./scripts/lib_sim_setup.py $(MODULE) $(BUILD_VSRC_DIR)

lint-all:
	./scripts/lint_all.sh

lint-run: clean copy_srcs
	$(PYTHON_EXEC) ./scripts/lib_lint_setup.py $(MODULE)
	touch $(BUILD_VSRC_DIR)/$(MODULE).sdc
	rm -rf $(BUILD_VSRC_DIR)/*_tb.v
	cd $(BUILD_VSRC_DIR) && ls *.v >> $(MODULE)_files.list
	@echo "Linting module $(MODULE)"
ifeq ($(LINT_SERVER),)
	cd $(BUILD_VSRC_DIR) && (echo exit | spyglass -licqueue -shell -project spyglass.prj -goals "lint/lint_rtl")
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) . $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_BUILD_DIR) lint-run MODULE=$(MODULE)'
	mkdir -p spyglass_reports
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_SRC_DIR)/spyglass/consolidated_reports/$(MODULE)_lint_lint_rtl/*.rpt spyglass_reports/.
endif

sim: copy_srcs
	@echo "Simulating module $(MODULE)"
ifeq ($(IS_ASYM),0)
	$(VLOG) $(wildcard $(BUILD_VSRC_DIR)/*.v)
	@./a.out $(TEST_LOG)
else
	$(VLOG) -DW_DATA_W=32 -DR_DATA_W=8 $(wildcard $(BUILD_VSRC_DIR)/*.v)
	@./a.out $(TEST_LOG); if [ $(VCD) != 0 ]; then mv uut.vcd uut1.vcd; fi
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=32 $(wildcard $(BUILD_VSRC_DIR)/*.v)
	@./a.out $(TEST_LOG); if [ $(VCD) != 0 ]; then mv uut.vcd uut2.vcd; fi
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=8 $(wildcard $(BUILD_VSRC_DIR)/*.v)
	@./a.out $(TEST_LOG); if [ $(VCD) != 0 ]; then mv uut.vcd uut3.vcd; fi
endif
ifeq ($(VCD),1)
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &
endif

test:
	./scripts/test.sh

clean:
	@rm -rf $(BUILD_VSRC_DIR)
	@rm -rf spyglass_reports
	@rm -f *.v *.vh *.c *.h *.tex *.rpt
	@rm -f *~ \#*\# a.out *.vcd *.pyc *.log

debug:

.PHONY: all sim clean debug

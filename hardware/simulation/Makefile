# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash

#select simulator
#default simulator
SIMULATOR ?=icarus

# Generate configuration when importing config_build.mk
GEN_CONFIG:=1
include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_SIM_DIR=$(REMOTE_BUILD_DIR)/hardware/simulation

#include simulation headers and sources
VHDR+=$(wildcard ./src/*.vh)
VSRC+=$(wildcard ./src/*.v)

ifeq ($(SYN),)
#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh)
VSRC+=$(wildcard ../src/*.v)
else
NODE ?= umc130
include ../syn/$(NODE)/sim.mk
VSRC+= ../syn/results/*.v
../syn/%.v:
	make -C ../syn build
endif

#exclude verilog testbench when using Verilator
ifeq ($(SIMULATOR), verilator)
VSRC:=$(filter-out $(wildcard ./src/*_tb.v), $(VSRC))
endif

#include local simulation segment
ifneq ($(wildcard sim_build.mk),)
include sim_build.mk
endif

include $(SIMULATOR).mk

UFLAGS+=VCD=$(VCD)
UFLAGS+=COV=$(COV)
UFLAGS+=SYN=$(SYN)
UFLAGS+=NODE=$(NODE)
UFLAGS+=COV_TEST=$(COV_TEST)

build: $(VHDR) $(VSRC) $(HEX)
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(SIM_SYNC_FLAGS) -avz --force --delete ../.. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR) $(UFLAGS)'
endif

CONSOLE_CMD=../../scripts/console.py -L

run: build
ifeq ($(SIM_SERVER),)
ifneq ($(CONSOLE_CMD),)
	@rm -f soc2cnsl cnsl2soc
	$(CONSOLE_CMD) $(TEST_LOG) &
endif
	bash -c "trap 'make kill-sim' INT TERM KILL EXIT; make exec"
else
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR) $(UFLAGS)'"
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.log .
ifeq ($(VCD),1)
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.vcd .
endif
ifeq ($(COV),1)
	sleep 1 && sync && scp -r $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/cov_work .
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/coverage_report_summary.rpt .
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/coverage_report_detail.rpt .
endif
endif
ifeq ($(VCD),1)
	make waves
endif

waves:
	if [ ! "`pgrep -u $(USER) gtkwave`" ]; then gtkwave -a uut.gtkw uut.vcd; fi &

fix-vcd:
	$(eval VCD_FILE:=$(shell ls *.vcd))
	@tail -n 1 $(VCD_FILE) | wc -c | xargs -I {} truncate $(VCD_FILE) -s -{}
	@echo "" >> $(VCD_FILE)

kill-sim:
	@if [ "`ps aux | grep $(USER) | grep console | grep python3 | grep -v grep`" ]; then \
	kill -9 $$(ps aux | grep $(USER) | grep console | grep python3 | grep -v grep | awk '{print $$2}'); fi
	@if [ -e *.vcd ]; then make fix-vcd; fi

kill-remote-sim:
	@echo "INFO: Remote simulator $(SIMULATOR) will be killed"
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'killall -q -u $(SIM_USER) -9 $(SIM_PROC); \
	make -C $(REMOTE_SIM_DIR) kill-sim'
ifeq ($(VCD),1)
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.vcd .
	make waves
endif

test: very-clean clean-test-log
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(SIM_SYNC_FLAGS) -avz --force --delete ../.. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) run-tests SIMULATOR=$(SIMULATOR) $(UFLAGS)'"
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.log .
ifeq ($(COV),1)
	sleep 1 && sync && scp -r $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/cov_work .
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/coverage_report_summary.rpt .
	sleep 1 && sync && scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/coverage_report_detail.rpt .
endif
else
	bash -c "trap 'make kill-sim' INT TERM KILL EXIT; make run-tests"
endif
ifneq ($(COV),1)
	diff test.log src/test.expected
else
	@echo "INFO: simulation code coverage is reserved for internal use only."
endif

run-tests: $(TEST_LIST)

gen-clean:
	@rm -f *.vh *.hex
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'if [ -f $(REMOTE_SIM_DIR)/Makefile ]; then make -C $(REMOTE_SIM_DIR) $@; fi'
endif

clean-test-log:
	rm -f test.log

debug:
	@echo NAME=$(NAME)
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo VFLAGS=$(VFLAGS)
	@echo $(TEST_LIST)

.PRECIOUS: uut.vcd

.PHONY: build run \
	waves fix-vcd \
	kill-sim kill-remote-sim \
	test run-tests \
	gen-clean clean-test-log \
	debug

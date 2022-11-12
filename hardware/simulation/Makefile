# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=/bin/bash

include ../../info.mk

REMOTE_BUILD_DIR=sandbox/$(NAME)
REMOTE_SIM_DIR=$(REMOTE_BUILD_DIR)/hardware/simulation

#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh)
VSRC+=$(wildcard ../src/*.v) $(wildcard ./*.v)

#exclude verilog testbench when using Verilator
ifeq ($(SIMULATOR), verilator)
VSRC:=$(filter-out $(wildcard *_tb.v), $(VSRC))
endif

#select simulator
#default simulator
SIMULATOR?=icarus
include $(SIMULATOR).mk

#include local simulation segment
ifneq ($(wildcard sim_build.mk),)
include sim_build.mk
endif

build: $(VHDR) $(VSRC)
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(SIM_SYNC_FLAGS) -avz --force ../.. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR) VCD=$(VCD)'
endif

run: build
ifeq ($(SIM_SERVER),)
ifneq ($(CONSOLE_CMD),)
	@rm -f soc2cnsl cnsl2soc
	$(CONSOLE_CMD) $(TEST_LOG) &
endif
	bash -c "trap 'make kill-sim' INT TERM KILL EXIT; make exec"
else
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_SIM_DIR) $@ SIMULATOR=$(SIMULATOR)'"
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.log .
ifeq ($(VCD),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.vcd .
endif
ifeq ($(DO_COV),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/$(NAME)_cov.rpt .
endif
endif
ifeq ($(VCD),1)
	if [ ! "`pgrep -u $(USER) gtkwave`" ]; then gtkwave -a uut.gtkw uut.vcd; fi &
endif	

waves:
	gtkwave  -a uut.gtkw uut.vcd &

kill-sim:
	@if [ "`ps aux | grep $(USER) | grep console | grep python3 | grep -v grep`" ]; then \
	kill -9 $$(ps aux | grep $(USER) | grep console | grep python3 | grep -v grep | awk '{print $$2}'); fi

kill-remote-sim:
	@echo "INFO: Remote simulator $(SIMULATOR) will be killed"
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'killall -q -u $(SIM_USER) -9 $(SIM_PROC); \
	make -C $(REMOTE_SIM_DIR) kill-sim'
ifeq ($(VCD),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_SIM_DIR)/*.vcd $(SIM_DIR)
endif

clean:
	@find . -type f -not \( -name "Makefile" -o -name "*.mk" -o -name "test.*" -o -name "*.v*" -o -path "./src*" \) -delete
	@rm -rf obj_dir ../../*.vh
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'if [ -f $(REMOTE_SIM_DIR)/Makefile ]; then make -C $(REMOTE_SIM_DIR) $@; fi'
endif


test: clean clean-test-log $(TEST_LIST)
	diff test.log test.expected

clean-test-log:
	rm -f test.log

debug:
	@echo NAME=$(NAME)
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo VFLAGS=$(VFLAGS)

.PRECIOUS: uut.vcd

.PHONY: build run clean kill-sim kill-remote-sim debug test $(TEST_LIST)


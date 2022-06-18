# This file becomes the simulation makefile when copied to the build
# directory

SHELL:=/bin/bash

# include core basic info
include ../info.mk

REMOTE_BUILD_DIR=sandbox/$(TOP_MODULE)_$(VERSION_STR)

#include the module's headers and sources
VHDR=$(wildcard ../vsrc/*.vh)
VSRC+=$(wildcard ../vsrc/*.v)

#include local simulation segment
ifneq ($(shell if [ -f simulation.mk ]; then echo yes; fi),)
include simulation.mk
endif

#select simulator
#default simulator
SIMULATOR?=icarus
ifeq ($(SIMULATOR), verilator)
include verilator.mk
else
include icarus.mk
endif

build: $(VHDR) $(VSRC)
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	scp $(SIM_SCP_FLAGS) ../*.mk $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	rsync $(SIM_SYNC_FLAGS) -avz --force --delete $(SIM_SYNC_FLAGS) ../vsrc $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
	rsync $(SIM_SYNC_FLAGS) -avz --force --delete $(SIM_SYNC_FLAGS) ../sim $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_BUILD_DIR)/sim $@ SIMULATOR=$(SIMULATOR)'
endif

run: build
ifeq ($(SIM_SERVER),)
	bash -c "trap 'make kill-sim' INT TERM KILL EXIT; make exec"
else
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_BUILD_DIR)/sim $@ SIMULATOR=$(SIMULATOR)'"
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/sim/sim.log .
ifeq ($(VCD),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/hardware/simulation/$(SIMULATOR)/*.vcd .
endif
endif
ifeq ($(VCD),1)
	if [ ! `pgrep -u $(USER) gtkwave` ]; then gtkwave uut.vcd; fi &
endif

kill-sim:
	@if [ "`ps aux | grep $(USER) | grep console | grep python3 | grep -v grep`" ]; then \
	kill -9 $$(ps aux | grep $(USER) | grep console | grep python3 | grep -v grep | awk '{print $$2}'); fi

kill-remote-sim:
	@echo "INFO: Remote simulator $(SIMULATOR) will be killed"
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'killall -q -u $(SIM_USER) -9 $(SIM_PROC); \
	make -C $(REMOTE_BUILD_DIR)/hardware/simulation/$(SIMULATOR) kill-sim'
ifeq ($(VCD),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/hardware/simulation/$(SIMULATOR)/*.vcd $(SIM_DIR)
endif

clean:
	@rm -rf *
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'if [ -f $(REMOTE_BUILD_DIR)/fpga/Makefile ]; then make -C $(REMOTE_BUILD_DIR)/sim clean; fi'
endif

test: $(TEST_LIST) 
	diff test.log test.expected

debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(VFLAGS)

.PHONY: build run clean kill-sim kill-remote-sim debug test


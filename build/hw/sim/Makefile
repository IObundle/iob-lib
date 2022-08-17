# This file becomes the simulation makefile when copied to the build
# directory

SHELL:=/bin/bash

include ../../info.mk

REMOTE_BUILD_DIR=sandbox/$(NAME)_$(VERSION_STR)

#include the module's headers and sources
VHDR+=$(wildcard ../vsrc/*.vh)
VSRC+=$(wildcard ../vsrc/*.v)

#select simulator
#default simulator
SIMULATOR?=icarus
include $(SIMULATOR).mk

#include local simulation segment
ifneq ($(wildcard simulation.mk),)
include simulation.mk
endif

build: $(VHDR) $(VSRC)
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(SIM_SYNC_FLAGS) -avz --force ../.. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hw/sim $@ TOP_MODULE=$(TOP_MODULE) SIMULATOR=$(SIMULATOR)'
endif

run: build
ifeq ($(SIM_SERVER),)
	bash -c "trap 'make kill-sim' INT TERM KILL EXIT; make exec"
else
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hw/sim $@ SIMULATOR=$(SIMULATOR)'"
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/hw/sim/sim.log .
ifeq ($(VCD),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/hw/sim/*.vcd .
endif
ifeq ($(DO_COV),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/hw/sim/iob_i2s_tdm_cov.rpt .
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
	make -C $(REMOTE_BUILD_DIR)/hw/sim kill-sim'
ifeq ($(VCD),1)
	scp $(SIM_SCP_FLAGS) $(SIM_USER)@$(SIM_SERVER):$(REMOTE_BUILD_DIR)/hw/sim/*.vcd $(SIM_DIR)
endif

clean:
	@find . -type f -not \( -name "Makefile" -o -name "*.mk" -o -name "*.expected" \) -delete
ifneq ($(SIM_SERVER),)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'if [ -f $(REMOTE_BUILD_DIR)/fpga/Makefile ]; then make -C $(REMOTE_BUILD_DIR)/hw/sim clean; fi'
endif


test: clean clean-test-log $(TEST_LIST)
	diff test.log test.expected

clean-test-log:
	rm -f test.log

debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(VFLAGS)

.PHONY: build run clean kill-sim kill-remote-sim debug test $(TEST_LIST)


# This file becomes the simulation makefile when copied to the build
# directory


include simulation.mk

VHDR=$(wildcard *.vh) $(wildcard ../vsrc/*.vh)

#include the module's testbench
ifeq ($(SIMULATOR),verilator)
VSRC_TMP=$(wildcard ../vsrc/*.v)
VSRC=$(filter-out src/$(TOP_MODULE)_tb.v, $(VSRC_TMP))
else
VSRC=$(wildcard *.v) $(wildcard ../vsrc/*.v)
endif

ifeq ($(VCD),1)
MACRO_LIST+=VCD
endif

build: $(VHDR) $(VSRC)
ifeq ($(SIM_SERVER),)
	make comp
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --force --exclude .git $(SIM_SYNC_FLAGS) .. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_ROOT_DIR) sim-build SIMULATOR=$(SIMULATOR) TEST_LOG=\"$(TEST_LOG)\"'
endif

run:
ifeq ($(SIM_SERVER),)
	bash -c "trap 'make kill-sim' INT TERM KILL EXIT; make exec"
else
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --force --exclude .git $(SIM_SYNC_FLAGS) .. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	bash -c "trap 'make kill-remote-sim' INT TERM KILL; ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'make -C $(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR) $@ SIMULATOR=$(SIMULATOR) TEST_LOG=\"$(TEST_LOG)\"'"
ifneq ($(TEST_LOG),)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR)/test.log .
endif
ifeq ($(VCD),1)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR)/*.vcd .
endif
endif
ifeq ($(VCD),1)
	if [ ! `pgrep -u $(USER) gtkwave` ]; then gtkwave uut.vcd; fi &
endif

ifeq ($(SIMULATOR), verilator)
include verilator.mk
else ifeq ($(SIMULATOR), icarus)
include icarus.mk
endif


kill-remote-sim:
	@echo "INFO: Remote simulator $(SIMULATOR) will be killed"
	ssh $(SIM_SSH_FLAGS) $(SIM_USER)@$(SIM_SERVER) 'killall -q -u $(SIM_USER) -9 $(SIM_PROC); \
	make -C $(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR) kill-sim'
ifeq ($(VCD),1)
	scp $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)/hardware/simulation/$(SIMULATOR)/*.vcd $(SIM_DIR)
endif

kill-sim:
	@if [ "`ps aux | grep $(USER) | grep console | grep python3 | grep -v grep`" ]; then \
	kill -9 $$(ps aux | grep $(USER) | grep console | grep python3 | grep -v grep | awk '{print $$2}'); fi



sim-clean:
	@find . -type f -not  \( $(NOCLEAN) \) -delete
ifneq ($(SIM_SERVER),)
	rsync -avz --delete --exclude .git .. $(SIM_USER)@$(SIM_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(REMOTE_ROOT_DIR); make sim-clean SIMULATOR=$(SIMULATOR)'
endif

debug:
	echo $(VHDR)
	echo $(VSRC)


.PHONY: build run debug clean

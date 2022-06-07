VHDR=$(wildcard ../vsrc/*.vh)
VSRC=$(wildcard ../vsrc/*.v)

#include the module's testbench
ifeq ($(SIMULATOR),verilator)
VSRC=$(filter-out src/$(TOP_MODULE)_tb.v, $(VSRC))
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

run: build
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

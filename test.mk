#build here
BUILD_VSRC_DIR:=.

# Default module
MODULE ?= iob_ram_2p
MODULE_DIR ?= $(shell find hardware -name $(MODULE))
ifneq ($(MODULE_DIR),)
include $(MODULE_DIR)/hardware.mk
else
$(info No such module $(MODULE))
endif

# Testbench
TB=$(wildcard $(MODULE_DIR)/*_tb.v)

# Defines
DEFINE=-DADDR_W=10 -DDATA_W=32
ifeq ($(VCD),1)
DEFINE+= -DVCD
endif

# Includes
INCLUDE=-Ibuild/hw/vsrc

# asymmetric memory present
IS_ASYM=$(shell echo $(VSRC) | grep asym)

#
# Simulate with Icarus Verilog
#
VLOG=iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

sim-sym:
	$(VLOG) $(VSRC) $(TB)
	@./a.out $(TEST_LOG)

sim-asym:
	$(VLOG) -DW_DATA_W=32 -DR_DATA_W=8 $(VSRC) $(TB)
	@./a.out $(TEST_LOG)
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=32 $(VSRC) $(TB)
	@./a.out $(TEST_LOG)
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=8 $(VSRC) $(TB)
	@./a.out $(TEST_LOG)

sim: $(VSRC) $(TB)
	@echo "Simulating module $(MODULE)"
ifeq ($(IS_ASYM),)
	make sim-sym
else
	make sim-asym
endif
ifeq ($(VCD),1)
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &
endif

# Rules
.PHONY: sim sim-sym sim-asym 

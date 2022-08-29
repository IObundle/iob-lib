# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile segment is included by Makefile and is used to test
# the modules in this repo
#

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
IS_ASYM=$(shell echo $(SRC) | grep asym)

AXI_GEN:=./software/python/axi_gen.py

#
# Simulate with Icarus Verilog
#
VLOG=iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

sim-sym:
	$(VLOG) $(SRC) $(TB)
	@./a.out $(TEST_LOG)

sim-asym:
	$(VLOG) -DW_DATA_W=32 -DR_DATA_W=8 $(SRC) $(TB)
	@./a.out $(TEST_LOG)
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=32 $(SRC) $(TB)
	@./a.out $(TEST_LOG)
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=8 $(SRC) $(TB)
	@./a.out $(TEST_LOG)

sim: $(SRC) $(TB)
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

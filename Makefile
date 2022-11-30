# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile simulates the hardware modules in this repo
#

SHELL=/bin/bash
export

#build here
LIB_DIR:=.
BUILD_VSRC_DIR:=.


all: sim

# Default module
MODULE ?= iob_ram_2p
MODULE_DIR ?= $(shell find hardware -name $(MODULE))
ifneq ($(MODULE_DIR),)
include $(MODULE_DIR)/hw_setup.mk
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
INCLUDE=-Ihardware/include

# asymmetric memory present
IS_ASYM=$(shell echo $(SRC) | grep asym)

AXI_GEN:=./scripts/if_gen.py

#
# Simulate with Icarus Verilog
#
VLOG=iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

sim: $(SRC) $(TB)
	@echo "Simulating module $(MODULE)"
ifeq ($(IS_ASYM),)
	$(VLOG) $(SRC) $(TB)
	@./a.out $(TEST_LOG)
else
	$(VLOG) -DW_DATA_W=32 -DR_DATA_W=8 $(SRC) $(TB)
	@./a.out $(TEST_LOG); if [ $$VCD != 0 ]; then mv uut.vcd uut1.vcd; fi
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=32 $(SRC) $(TB)
	@./a.out $(TEST_LOG); if [ $$VCD != 0 ]; then mv uut.vcd uut2.vcd; fi
	$(VLOG) -DW_DATA_W=8 -DR_DATA_W=8 $(SRC) $(TB)
	@./a.out $(TEST_LOG); if [ $$VCD != 0 ]; then mv uut.vcd uut3.vcd; fi
endif
ifeq ($(VCD),1)
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &
endif

clean:
	@rm -f *.v *.vh *.c *.h *.tex
	@rm -f *~ \#*\# a.out *.vcd *.pyc *.log

debug:

.PHONY: all sim clean debug

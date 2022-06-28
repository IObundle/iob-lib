#
# Test Memory Modules
#
# Usage:
# 	- make all: run make test
# 	- make test: simulate all memory modules with testbench files
# 	- make sim MEM_MODULE_DIR=<path/to/mem/module>: simulation individual mem
#

ROOT_DIR=.
HW_DIR=$(ROOT_DIR)/hardware
MEM_DIR=$(ROOT_DIR)

# Paths to memories
MEM_HW_DIRS:= fifo ram regfile rom
MEM_TB_FILES:=

# Find MEM dirs with testbench files
$(foreach m, $(MEM_HW_DIRS), $(eval MEM_TB_FILES+=$(shell find $(HW_DIR)/$(m) -name *_tb.v -not -path './submodules/*')))
MEM_TEST_DIRS:=$(dir $(MEM_TB_FILES))

# Get tested memory modules file names
MEM_MODULES:=
$(foreach d, $(MEM_TEST_DIRS), $(eval MEM_MODULES+=$(shell basename $(shell find $(d) -name *.v -not -name *_tb.v))))

# Default mem dir
MEM_MODULE_DIR ?= $(patsubst %/, %, $(firstword $(MEM_TEST_DIRS)))
MEM_NAME:=$(notdir $(shell find $(MEM_MODULE_DIR) -name *.v -not -name *_tb.v))
defmacro:=-D
incdir:=-I

# Defines
DEFINE+=$(defmacro)ADDR_W=10
DEFINE+=$(defmacro)DATA_W=32
ifeq ($(VCD),1)
DEFINE+=$(defmacro)VCD
endif

# Includes
INCLUDE+=$(incdir)$(HW_DIR)/include

# Sources
ifneq ($(MEM_MODULE_DIR),)
include $(MEM_MODULE_DIR)/hardware.mk
endif

# Submodules
ifneq ($(filter iob_ram_2p_asym, $(HW_MODULES)),)
include $(MEM_DIR)/hardware/ram/iob_ram_2p/hardware.mk
endif

# Testbench
VSRC+=$(wildcard $(MEM_MODULE_DIR)/*_tb.v)

# list of asymmetric memories
IS_ASYM=$(shell echo $(MEM_NAME) | grep fifo)
IS_ASYM+=$(shell echo $(MEM_NAME) | grep 2p)
IS_ASYM+=$(shell echo $(MEM_NAME) | grep dp)

all: test

#
# Simulate
#

# Icarus Verilog simulator flags
VLOG=iverilog -W all -g2005-sv $(INCLUDE) $(DEFINE)

sim: $(VSRC) 
	@echo "\n\nSimulating module $(MEM_NAME)\n\n"
ifeq ($(IS_ASYM),)
	make sim-sym
else
	make sim-asym
endif
ifeq ($(VCD),1)
	@if [ ! `pgrep gtkwave` ]; then gtkwave uut.vcd; fi &
endif

sim-sym:
	$(VLOG) $(VSRC)
	@./a.out $(TEST_LOG)

sim-asym: $(VSRC)
	$(VLOG) $(defmacro)W_DATA_W=32 $(defmacro)R_DATA_W=8 $(VSRC)
	@./a.out $(TEST_LOG)
	$(VLOG) $(defmacro)W_DATA_W=8 $(defmacro)R_DATA_W=32 $(VSRC)
	@./a.out $(TEST_LOG)
	$(VLOG) $(defmacro)W_DATA_W=8 $(defmacro)R_DATA_W=8 $(VSRC)
	@./a.out $(TEST_LOG)

sim-all: $(MEM_TEST_DIRS)
	@echo "Listing all modules: $(MEM_MODULES)"

$(MEM_TEST_DIRS):
	make sim MEM_MODULE_DIR=$(@D)

#
# Test
#
sim-test:
	make sim-all VCD=0 TEST_LOG=">> test.log"

test: clean sim-test
	@if [ `grep -c "ERROR" test.log` != 0 ]; then exit 1; fi

#
# Clean
#

clean:
	@rm -f *~ \#*\# a.out *.vcd *.drom *.png *.pyc *.log

# Rules
.PHONY: sim sim-sym sim-asym sim-all \
	$(MEM_TEST_DIRS) \
	sim-test test \
	clean

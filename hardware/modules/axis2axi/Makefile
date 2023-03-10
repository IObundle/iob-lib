LIB_DIR := ../../..
MEM_DIR := $(LIB_DIR)
incdir := -I

# Need to include axi.vh file. No other folder contains a testbench so I temporarely added AXI as a submodule, which contains the axi.vh file
AXI_DIR := $(LIB_DIR)/submodules/AXI

# Default rule
run: all

include hardware.mk

INCLUDE+=$(incdir)$(LIB_DIR)/hardware/modules

VHDR += $(LIB_DIR)/hardware/modules/iob_lib.vh

# Testbench
VSRC += $(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v
VSRC += $(LIB_DIR)/hardware/modules/ram/iob_ram_t2p/iob_ram_t2p.v
VSRC += iob_reg.v
VSRC += iob_reg_r.v
VSRC += iob_reg_e.v
VSRC += iob_reg_re.v
VSRC += iob_counter.v
VSRC += iob_asym_converter.v
VSRC += axis2axi_tb.v
VSRC += AxiDelay.v 

all: $(VHDR) $(VSRC)
	iverilog $(VSRC) $(INCLUDE) -DVCD
	./a.out

clean:
	@rm -f a.out uut.vcd $(THIS_VHDR)

.PHONY: clean
	
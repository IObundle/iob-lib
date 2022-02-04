
#icarus verilog simulator
VLOG:=iverilog -W all -g2005-sv

VSRC:=iob2axi.v iob2axi_wr.v iob2axi_rd.v iob2axi_tb.v
VSRC+=../../submodules/AXI/rtl/axi_ram.v

INCLUDE:=../include

VCD_FILE:=uut.vcd

a.out: $(VSRC)
	$(VLOG) -I $(INCLUDE) -D VCD $(VSRC)

$(VCD_FILE): a.out
	./a.out

sim: $(VCD_FILE)

sim-waves: $(VCD_FILE)
	gtkwave -a waves.gtkw $(VCD_FILE) &

clean:
	@rm -f a.out *~ $(VCD_FILE)

.PRECIOUS: $(VCD_FILE)
	
.PHONY: sim sim-waves clean
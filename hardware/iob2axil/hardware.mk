INCLUDE+=$(incdir)$(AXI_DIR)/hardware/include

VSRC+=iob2axil.v
iob2axil.v:$(AXI_DIR)/hardware/iob2axil/iob2axil.v
	cp $< .

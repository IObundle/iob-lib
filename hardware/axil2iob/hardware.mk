INCLUDE+=$(incdir)$(AXI_DIR)/hardware/include

VSRC+=axil2iob.v
axil2iob.v:$(AXI_DIR)/hardware/axil2iob/axil2iob.v
	cp $< .

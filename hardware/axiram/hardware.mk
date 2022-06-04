include $(AXI_DIR)/config.mk

VSRC+=axi_ram.v
axi_ram.v:$(V_AXI_DIR)/rtl/axi_ram.v
	cp $< .

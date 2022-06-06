VSRC+=axi_ram.v
axi_ram.v: $(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v
	cp $< $(BUILD_VSRC_DIR)

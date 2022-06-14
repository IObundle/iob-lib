VSRC+=$(BUILD_SRC_DIR)/axi_ram.v
$(BUILD_SRC_DIR)/axi_ram.v: $(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v
	cp $< $(BUILD_SRC_DIR)

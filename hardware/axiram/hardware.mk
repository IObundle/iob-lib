
ifneq (axiram,$(filter axiram, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axiram

# Sources
VSRC+=$(BUILD_SRC_DIR)/axi_ram.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/axi_ram.v: $(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v
	cp $< $(BUILD_SRC_DIR)

endif

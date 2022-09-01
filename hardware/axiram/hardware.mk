ifeq ($(filter axiram, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axiram

# Sources
SRC+=$(BUILD_VSRC_DIR)/axi_ram.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/axi_ram.v: $(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v
	cp $< $(BUILD_VSRC_DIR)

endif

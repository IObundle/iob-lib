ifeq ($(filter iob_wstrb2byte_offset, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_wstrb2byte_offset

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_wstrb2byte_offset.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_wstrb2byte_offset.v: $(LIB_DIR)/hardware/iob_wstrb2byte_offset/iob_wstrb2byte_offset.v
	cp $< $@

endif

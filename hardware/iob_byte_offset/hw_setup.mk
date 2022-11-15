ifeq ($(filter iob_byte_offset, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_byte_offset

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_byte_offset.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_byte_offset.v: $(LIB_DIR)/hardware/iob_byte_offset/iob_byte_offset.v
	cp $< $(BUILD_VSRC_DIR)

endif

ifeq ($(filter iob2axil, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2axil

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob2axil.v

# Copy the sources to the build directoy
$(BUILD_VSRC_DIR)/iob2axil.v: $(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $(BUILD_VSRC_DIR)

endif

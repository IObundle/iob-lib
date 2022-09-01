
ifeq ($(filter iob_reg, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg.v: $(LIB_DIR)/hardware/iob_reg/iob_reg.v
	cp $< $(BUILD_VSRC_DIR)

endif

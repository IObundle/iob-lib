ifeq ($(filter iob_sipo_reg_are, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_sipo_reg_are

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_sipo_reg_are.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_sipo_reg_are.v: $(LIB_DIR)/hardware/iob_sipo_reg_are/iob_sipo_reg_are.v
	cp $< $(BUILD_VSRC_DIR)

endif

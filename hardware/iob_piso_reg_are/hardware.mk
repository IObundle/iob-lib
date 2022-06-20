
ifneq (iob_piso_reg_are,$(filter iob_piso_reg_are, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_piso_reg_are

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_piso_reg_are.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/iob_piso_reg_are.v:hardware/iob_piso_reg_are/iob_piso_reg_are.v
	cp $< $(BUILD_SRC_DIR)

endif

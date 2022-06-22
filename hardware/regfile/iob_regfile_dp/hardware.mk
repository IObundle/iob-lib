
ifeq ($(filter iob_regfile_dp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_regfile_dp

# Sources 
VSRC+=$(BUILD_VSRC_DIR)/iob_regfile_dp.v

# Copy the sources to build directory
$(BUILD_VSRC_DIR)/iob_regfile_dp.v:hardware/regfile/iob_regfile_dp/iob_regfile_dp.v
	cp $< $(BUILD_VSRC_DIR)

endif

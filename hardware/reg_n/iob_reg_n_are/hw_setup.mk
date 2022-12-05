ifeq ($(filter iob_reg_n_are, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_n_are

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_n_are.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_n_are.v: $(LIB_DIR)/hardware/reg_n/iob_reg_n_are/iob_reg_n_are.v
	cp $< $(BUILD_VSRC_DIR)

endif

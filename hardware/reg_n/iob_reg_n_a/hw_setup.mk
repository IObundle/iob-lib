ifeq ($(filter iob_reg_n_a, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_n_a

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_n_a.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_n_a.v: $(LIB_DIR)/hardware/reg_n/iob_reg_n_a/iob_reg_n_a.v
	cp $< $(BUILD_VSRC_DIR)

endif

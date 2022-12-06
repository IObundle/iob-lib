ifeq ($(filter iob_reg_ar, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_ar

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_ar.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_ar.v: $(LIB_DIR)/hardware/reg/iob_reg_ar/iob_reg_ar.v
	cp $< $(BUILD_VSRC_DIR)

endif

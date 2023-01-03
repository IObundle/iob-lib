ifeq ($(filter iob_reg_r, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_r

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_r.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_r.v: $(LIB_DIR)/hardware/reg/iob_reg_r/iob_reg_r.v
	cp $< $@

endif

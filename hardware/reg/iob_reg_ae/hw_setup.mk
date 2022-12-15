ifeq ($(filter iob_reg_ae, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_ae

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_ae.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_ae.v: $(LIB_DIR)/hardware/reg/iob_reg_ae/iob_reg_ae.v
	cp $< $@

endif

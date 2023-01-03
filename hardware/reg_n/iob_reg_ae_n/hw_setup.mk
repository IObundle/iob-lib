ifeq ($(filter iob_reg_ae_n, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_ae_n

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_ae_n.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_ae_n.v: $(LIB_DIR)/hardware/reg_n/iob_reg_ae_n/iob_reg_ae_n.v
	cp $< $@

endif

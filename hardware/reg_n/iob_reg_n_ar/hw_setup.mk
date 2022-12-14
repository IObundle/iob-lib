ifeq ($(filter iob_reg_n_ar, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_n_ar

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_n_ar.v

# Copy the sources to the build directory 
%/iob_reg_n_ar.v: $(LIB_DIR)/hardware/reg_n/iob_reg_n_ar/iob_reg_n_ar.v
	cp $< $@

endif

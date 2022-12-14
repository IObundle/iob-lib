ifeq ($(filter iob_reg_a, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_a

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_a.v

# Copy the sources to the build directory 
%/iob_reg_a.v: $(LIB_DIR)/hardware/reg/iob_reg_a/iob_reg_a.v
	cp $< $@

endif

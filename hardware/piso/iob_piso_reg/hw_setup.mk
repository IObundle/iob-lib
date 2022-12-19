ifeq ($(filter iob_piso_reg, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_piso_reg

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_piso_reg.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_piso_reg.v: $(LIB_DIR)/hardware/piso/iob_piso_reg/iob_piso_reg.v
	cp $< $@

endif

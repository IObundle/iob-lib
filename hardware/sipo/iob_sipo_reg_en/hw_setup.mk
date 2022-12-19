ifeq ($(filter iob_sipo_reg_en, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_sipo_reg_en

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_sipo_reg_en.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_sipo_reg_en.v: $(LIB_DIR)/hardware/sipo/iob_sipo_reg_en/iob_sipo_reg_en.v
	cp $< $@

endif

ifneq (iob_sipo_reg_are,$(filter iob_sipo_reg_are, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_sipo_reg_are

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_sipo_reg_are/iob_sipo_reg_are.v

endif

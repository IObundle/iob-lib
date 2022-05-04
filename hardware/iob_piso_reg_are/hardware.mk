ifneq (iob_piso_reg_are,$(filter iob_piso_reg_are, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_piso_reg_are

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_piso_reg_are/iob_piso_reg_are.v

endif

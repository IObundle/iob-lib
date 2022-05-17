ifeq ($(filter iob_reg, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_reg/iob_reg.v

endif

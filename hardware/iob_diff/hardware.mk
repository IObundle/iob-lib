ifeq ($(filter iob_diff, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_diff

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_diff/iob_diff.v

endif

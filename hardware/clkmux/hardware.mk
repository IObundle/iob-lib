ifneq (clkmux,$(filter clkmux, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=clkmux

# Sources
VSRC+=$(LIB_DIR)/hardware/clkmux/clkmux.v

endif

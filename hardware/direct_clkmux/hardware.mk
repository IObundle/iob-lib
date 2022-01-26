ifneq (direct_clkmux,$(filter direct_clkmux, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=direct_clkmux

# Sources
VSRC+=$(LIB_DIR)/hardware/direct_clkmux/direct_clkmux.v

endif

ifneq (iob_clkmux,$(filter iob_clkmux, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_clkmux

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_clkmux/iob_clkmux.v

endif

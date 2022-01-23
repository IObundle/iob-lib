ifneq (direct_clkmux,$(filter direct_clkmux, $(MODULES)))

# Add to modules list
MODULES+=direct_clkmux

# Sources
VSRC+=$(LIB_DIR)/hardware/direct_clkmux/direct_clkmux.v

endif

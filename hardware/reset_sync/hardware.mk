ifneq (reset_sync,$(filter reset_sync, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=reset_sync

# Sources
VSRC+=$(LIB_DIR)/hardware/reset_sync/reset_sync.v

endif

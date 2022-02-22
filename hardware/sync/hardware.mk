ifneq (sync,$(filter sync, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=sync

# Sources
VSRC+=$(LIB_DIR)/hardware/sync/sync.v

endif

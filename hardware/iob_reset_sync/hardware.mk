ifneq (iob_reset_sync,$(filter iob_reset_sync, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_reset_sync

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_reset_sync/iob_reset_sync.v

endif

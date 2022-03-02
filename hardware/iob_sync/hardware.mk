ifneq (iob_sync,$(filter iob_sync, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_sync

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_sync/iob_sync.v

endif

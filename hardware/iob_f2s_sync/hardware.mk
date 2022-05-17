ifeq ($(filter iob_f2s_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_f2s_sync

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_f2s_sync/iob_f2s_sync.v

endif

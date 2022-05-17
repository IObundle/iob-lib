ifeq ($(filter iob_s2f_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_s2f_sync

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_s2f_sync/iob_s2f_sync.v

endif

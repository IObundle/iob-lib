ifeq ($(filter iob_f2s_1bit_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_f2s_1bit_sync

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_f2s_1bit_sync/iob_f2s_1bit_sync.v

endif

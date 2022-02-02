ifneq (iob_modcnt,$(filter iob_modcnt, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_modcnt

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_modcnt/iob_modcnt.v

endif

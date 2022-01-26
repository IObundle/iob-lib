ifneq (iob_merge,$(filter iob_merge, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_merge

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_merge/iob_merge.v

endif

ifneq (iob_split,$(filter iob_split, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_split

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_split/iob_split.v

endif

ifneq (iob_merge,$(filter iob_merge, $(MODULES)))

# Add to modules list
MODULES+=iob_merge

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_merge/iob_merge.v

endif

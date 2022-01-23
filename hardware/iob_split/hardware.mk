ifneq (iob_split,$(filter iob_split, $(MODULES)))

# Add to modules list
MODULES+=iob_split

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_split/iob_split.v

endif

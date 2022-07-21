ifneq (alt_iobuf,$(filter alt_iobuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=alt_iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/alt_iobuf/alt_iobuf.v

endif

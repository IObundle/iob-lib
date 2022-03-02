ifneq (iob_iobuf,$(filter iob_iobuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_iobuf/iob_iobuf.v

endif

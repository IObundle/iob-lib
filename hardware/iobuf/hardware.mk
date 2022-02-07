ifneq (iobuf,$(filter iobuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/iobuf/iobuf.v

endif

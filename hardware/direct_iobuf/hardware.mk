ifneq (direct_iobuf,$(filter direct_iobuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=direct_iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/direct_iobuf/direct_iobuf.v

endif

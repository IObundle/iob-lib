ifneq (direct_iobuf,$(filter direct_iobuf, $(MODULES)))

# Add to modules list
MODULES+=direct_iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/direct_iobuf/direct_iobuf.v

endif

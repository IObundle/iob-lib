ifneq (direct_clkbuf,$(filter direct_clkbuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=direct_clkbuf

# Sources
VSRC+=$(LIB_DIR)/hardware/direct_clkbuf/direct_clkbuf.v

endif

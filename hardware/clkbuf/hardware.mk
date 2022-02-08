ifneq (clkbuf,$(filter clkbuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=clkbuf

# Sources
VSRC+=$(LIB_DIR)/hardware/clkbuf/clkbuf.v

endif

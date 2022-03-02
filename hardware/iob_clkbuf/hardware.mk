ifneq (iob_clkbuf,$(filter iob_clkbuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_clkbuf

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_clkbuf/iob_clkbuf.v

endif

ifneq (direct_clkbuf,$(filter direct_clkbuf, $(MODULES)))

# Add to modules list
MODULES+=direct_clkbuf

# Sources
VSRC+=$(LIB_DIR)/hardware/direct_clkbuf/direct_clkbuf.v

endif

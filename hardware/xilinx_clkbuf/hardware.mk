ifneq (xilinx_clkbuf,$(filter xilinx_clkbuf, $(MODULES)))

# Add to modules list
MODULES+=xilinx_clkbuf

# Sources
VSRC+=$(LIB_DIR)/hardware/xilinx_clkbuf/xilinx_clkbuf.v

endif

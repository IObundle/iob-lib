ifneq (xilinx_clkbuf,$(filter xilinx_clkbuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=xilinx_clkbuf

# Sources
VSRC+=$(LIB_DIR)/hardware/xilinx_clkbuf/xilinx_clkbuf.v

endif

ifneq (xilinx_clkmux,$(filter xilinx_clkmux, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=xilinx_clkmux

# Sources
VSRC+=$(LIB_DIR)/hardware/xilinx_clkmux/xilinx_clkmux.v

endif

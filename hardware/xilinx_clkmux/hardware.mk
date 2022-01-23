ifneq (xilinx_clkmux,$(filter xilinx_clkmux, $(MODULES)))

# Add to modules list
MODULES+=xilinx_clkmux

# Sources
VSRC+=$(LIB_DIR)/hardware/xilinx_clkmux/xilinx_clkmux.v

endif

ifneq (xilinx_iobuf,$(filter xilinx_iobuf, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=xilinx_iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/xilinx_iobuf/xilinx_iobuf.v

endif

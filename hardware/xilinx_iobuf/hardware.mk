ifneq (xilinx_iobuf,$(filter xilinx_iobuf, $(MODULES)))

# Add to modules list
MODULES+=xilinx_iobuf

# Sources
VSRC+=$(LIB_DIR)/hardware/xilinx_iobuf/xilinx_iobuf.v

endif

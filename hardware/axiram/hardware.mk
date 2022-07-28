ifneq (axiram,$(filter axiram, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=axiram

# Sources
VSRC+=$(LIB_DIR)/submodules/VERILOG_AXI/rtl/axi_ram.v

endif

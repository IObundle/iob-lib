ifneq (axiram,$(filter axiram, $(HW_MODULES)))

include $(AXI_DIR)/config.mk

# Add to modules list
HW_MODULES+=axiram

# Sources
VSRC+=$(V_AXI_DIR)/rtl/axi_ram.v

endif

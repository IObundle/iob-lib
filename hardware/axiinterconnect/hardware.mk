ifneq (axiinterconnect,$(filter axiinterconnect, $(HW_MODULES)))

include $(AXI_DIR)/config.mk

# Add to modules list
HW_MODULES+=axiinterconnect

# Sources
VSRC+=$(V_AXI_DIR)/rtl/axi_interconnect.v
VSRC+=$(V_AXI_DIR)/rtl/arbiter.v
VSRC+=$(V_AXI_DIR)/rtl/priority_encoder.v

endif

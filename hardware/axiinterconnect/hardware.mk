
ifneq (axiinterconnect,$(filter axiinterconnect, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=axiinterconnect


VSRC+=$(BUILD_SRC_DIR)/axi_interconnect.v $(BUILD_SRC_DIR)/arbiter.v $(BUILD_SRC_DIR)/priority_encoder.v


$(BUILD_SRC_DIR)/axi_interconnect.v: $(V_AXI_DIR)/rtl/axi_interconnect.v
	cp $< $(BUILD_SRC_DIR)

$(BUILD_SRC_DIR)/arbiter.v: $(V_AXI_DIR)/rtl/arbiter.v
	cp $< $(BUILD_SRC_DIR)

$(BUILD_SRC_DIR)/priority_encoder.v: $(V_AXI_DIR)/rtl/priority_encoder.v
	cp $< $(BUILD_SRC_DIR)


endif

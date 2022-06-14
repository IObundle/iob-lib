include $(LIB_DIR)/hardware/ram/iob_ram_dp/hardware.mk

VSRC+=$(BUILD_SRC_DIR)/iob_ram_dp_be.v
$(BUILD_SRC_DIR)/iob_ram_dp_be.v:$(LIB_DIR)/hardware/ram/iob_ram_dp_be/iob_ram_dp_be.v
	cp $< $(BUILD_SRC_DIR)

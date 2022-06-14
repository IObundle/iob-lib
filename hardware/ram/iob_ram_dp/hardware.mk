
VSRC+=$(BUILD_SRC_DIR)/iob_ram_dp.v
$(BUILD_SRC_DIR)/iob_ram_dp.v:$(LIB_DIR)/hardware/ram/iob_ram_dp/iob_ram_dp.v
	cp $< $(BUILD_SRC_DIR)

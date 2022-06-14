
VSRC+=$(BUILD_SRC_DIR)/iob_rom_dp.v
$(BUILD_SRC_DIR)/iob_rom_dp.v:$(LIB_DIR)/hardware/rom/iob_rom_dp/iob_rom_dp.v
	cp $< $(BUILD_SRC_DIR)


VSRC+=$(BUILD_SRC_DIR)/iob_rom_tdp.v
$(BUILD_SRC_DIR)/iob_rom_tdp.v:$(LIB_DIR)/hardware/rom/iob_rom_tdp/iob_rom_tdp.v
	cp $< $(BUILD_SRC_DIR)

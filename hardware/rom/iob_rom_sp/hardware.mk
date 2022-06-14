
VSRC+=$(BUILD_SRC_DIR)/iob_rom_sp.v
$(BUILD_SRC_DIR)/iob_rom_sp.v:$(LIB_DIR)/hardware/rom/iob_rom_sp/iob_rom_sp.v
	cp $< $(BUILD_SRC_DIR)

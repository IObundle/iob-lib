
VSRC+=$(BUILD_SRC_DIR)/iob_ram_tdp.v
$(BUILD_SRC_DIR)/iob_ram_tdp.v:$(LIB_DIR)/hardware/ram/iob_ram_tdp/iob_ram_tdp.v
	cp $< $(BUILD_SRC_DIR)

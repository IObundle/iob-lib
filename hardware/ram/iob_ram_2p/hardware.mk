VSRC+=$(BUILD_SRC_DIR)/iob_ram_2p.v
$(BUILD_SRC_DIR)/iob_ram_2p.v: $(LIB_DIR)/hardware/ram/iob_ram_2p/iob_ram_2p.v
	cp $< $(BUILD_SRC_DIR)

VSRC+=$(BUILD_SRC_DIR)/iob_ram_sp.v
$(BUILD_SRC_DIR)/iob_ram_sp.v: $(LIB_DIR)/hardware/ram/iob_ram_sp/iob_ram_sp.v
	cp $< $(BUILD_SRC_DIR)

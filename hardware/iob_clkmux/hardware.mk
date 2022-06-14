
VSRC+=$(BUILD_SRC_DIR)/iob_clkmux.v
$(BUILD_SRC_DIR)/iob_clkmux.v: $(LIB_DIR)/hardware/iob_clkmux/iob_clkmux.v
	cp $< $(BUILD_SRC_DIR)

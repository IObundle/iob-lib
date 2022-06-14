
VSRC+=$(BUILD_SRC_DIR)/iob_diff.v
$(BUILD_SRC_DIR)/iob_diff.v:$(LIB_DIR)/hardware/iob_diff/iob_diff.v
	cp $< $(BUILD_SRC_DIR)

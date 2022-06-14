
VSRC+=$(BUILD_SRC_DIR)/iob_split.v
$(BUILD_SRC_DIR)/iob_split.v:$(LIB_DIR)/hardware/iob_split/iob_split.v
	cp $< $(BUILD_SRC_DIR)

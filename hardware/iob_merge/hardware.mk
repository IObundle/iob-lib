
VSRC+=$(BUILD_SRC_DIR)/iob_merge.v
$(BUILD_SRC_DIR)/iob_merge.v:$(LIB_DIR)/hardware/iob_merge/iob_merge.v
	cp $< $(BUILD_SRC_DIR)

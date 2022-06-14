
VSRC+=$(BUILD_SRC_DIR)/iob_sync.v
$(BUILD_SRC_DIR)/iob_sync.v:$(LIB_DIR)/hardware/iob_sync/iob_sync.v
	cp $< $(BUILD_SRC_DIR)

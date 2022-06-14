
VSRC+=$(BUILD_SRC_DIR)/iob_reset_sync.v
$(BUILD_SRC_DIR)/iob_reset_sync.v:$(LIB_DIR)/hardware/iob_reset_sync/iob_reset_sync.v
	cp $< $(BUILD_SRC_DIR)

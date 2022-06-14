
VSRC+=$(BUILD_SRC_DIR)/iob_s2f_sync.v
$(BUILD_SRC_DIR)/iob_s2f_sync.v:$(LIB_DIR)/hardware/iob_s2f_sync/iob_s2f_sync.v
	cp $< $(BUILD_SRC_DIR)

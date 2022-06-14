
VSRC+=$(BUILD_SRC_DIR)/iob_f2s_1bit_sync.v
$(BUILD_SRC_DIR)/iob_f2s_1bit_sync.v:$(LIB_DIR)/hardware/iob_f2s_1bit_sync/iob_f2s_1bit_sync.v
	cp $< $(BUILD_SRC_DIR)

VSRC+=$(BUILD_SRC_DIR)/iob_reverse.v
$(BUILD_SRC_DIR)/iob_reverse.v:$(LIB_DIR)/hardware/iob_reverse/iob_reverse.v
	cp $< $(BUILD_SRC_DIR)

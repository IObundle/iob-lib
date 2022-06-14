
VSRC+=$(BUILD_SRC_DIR)/iob_gray2bin.v
$(BUILD_SRC_DIR)/iob_gray2bin.v:$(LIB_DIR)/hardware/fifo/iob_gray2bin/iob_gray2bin.v
	cp $< $(BUILD_SRC_DIR)

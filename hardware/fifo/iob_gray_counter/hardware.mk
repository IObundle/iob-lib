
VSRC+=$(BUILD_SRC_DIR)/iob_gray_counter.v
$(BUILD_SRC_DIR)/iob_gray_counter.v:$(LIB_DIR)/hardware/fifo/iob_gray_counter/iob_gray_counter.v
	cp $< $(BUILD_SRC_DIR)

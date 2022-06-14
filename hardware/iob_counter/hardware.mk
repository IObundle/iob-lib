
VSRC+=$(BUILD_SRC_DIR)/iob_counter.v
$(BUILD_SRC_DIR)/iob_counter.v:$(LIB_DIR)/hardware/iob_counter/iob_counter.v
	cp $< $(BUILD_SRC_DIR)

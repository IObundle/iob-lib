
VSRC+=$(BUILD_SRC_DIR)/iob_iobuf.v
$(BUILD_SRC_DIR)/iob_iobuf.v:$(LIB_DIR)/hardware/iob_iobuf/iob_iobuf.v
	cp $< $(BUILD_SRC_DIR)

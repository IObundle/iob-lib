
VSRC+=$(BUILD_SRC_DIR)/iob_acc.v
$(BUILD_SRC_DIR)/iob_acc.v:$(LIB_DIR)/hardware/iob_acc/iob_acc.v
	cp $< $(BUILD_SRC_DIR)

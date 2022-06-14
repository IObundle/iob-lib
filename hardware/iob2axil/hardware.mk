
VSRC+=$(BUILD_SRC_DIR)/iob2axil.v
$(BUILD_SRC_DIR)/iob2axil.v:$(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $(BUILD_SRC_DIR)

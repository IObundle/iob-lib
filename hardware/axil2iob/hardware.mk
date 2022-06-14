
VSRC+=$(BUILD_SRC_DIR)/axil2iob.v
$(BUILD_SRC_DIR)/axil2iob.v:$(LIB_DIR)/hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_SRC_DIR)

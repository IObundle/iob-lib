
VSRC+=$(BUILD_SRC_DIR)/iob_edge_detect.v
$(BUILD_SRC_DIR)/iob_edge_detect.v:$(LIB_DIR)/hardware/iob_edge_detect/iob_edge_detect.v
	cp $< $(BUILD_SRC_DIR)

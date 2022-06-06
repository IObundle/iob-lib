
VSRC+=iob_edge_detect.v
iob_edge_detect.v:$(LIB_DIR)/hardware/iob_edge_detect/iob_edge_detect.v
	cp $< $(BUILD_VSRC_DIR)


VSRC+=iob_iobuf.v
iob_iobuf.v:$(LIB_DIR)/hardware/iob_iobuf/iob_iobuf.v
	cp $< $(BUILD_VSRC_DIR)

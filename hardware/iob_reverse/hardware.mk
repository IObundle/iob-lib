VSRC+=iob_reverse.v
iob_reverse.v:$(LIB_DIR)/hardware/iob_reverse/iob_reverse.v
	cp $< $(BUILD_VSRC_DIR)

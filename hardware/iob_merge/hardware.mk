
VSRC+=iob_merge.v
iob_merge.v:$(LIB_DIR)/hardware/iob_merge/iob_merge.v
	cp $< $(BUILD_VSRC_DIR)

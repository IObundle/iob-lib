
VSRC+=iob_s2f_sync.v
iob_s2f_sync.v:$(LIB_DIR)/hardware/iob_s2f_sync/iob_s2f_sync.v
	cp $< $(BUILD_VSRC_DIR)

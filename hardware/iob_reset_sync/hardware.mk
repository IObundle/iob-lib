
VSRC+=iob_reset_sync.v
iob_reset_sync.v:$(LIB_DIR)/hardware/iob_reset_sync/iob_reset_sync.v
	cp $< $(BUILD_VSRC_DIR)

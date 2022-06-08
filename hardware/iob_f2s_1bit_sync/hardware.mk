
VSRC+=iob_f2s_1bit_sync.v
iob_f2s_1bit_sync.v:$(LIB_DIR)/hardware/iob_f2s_1bit_sync/iob_f2s_1bit_sync.v
	cp $< $(BUILD_DIR)/vsrc

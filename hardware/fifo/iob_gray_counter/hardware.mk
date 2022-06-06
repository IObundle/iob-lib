
VSRC+=iob_gray_counter.v
iob_gray_counter.v:$(LIB_DIR)/hardware/fifo/iob_gray_counter/iob_gray_counter.v
	cp $< $(BUILD_VSRC_DIR)


VSRC+=iob_counter.v
iob_counter.v:$(LIB_DIR)/hardware/iob_counter/iob_counter.v
	cp $< $(BUILD_DIR)/vsrc

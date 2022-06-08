
VSRC+=iob_clkmux.v
iob_clkmux.v: $(LIB_DIR)/hardware/iob_clkmux/iob_clkmux.v
	cp $< $(BUILD_DIR)/vsrc

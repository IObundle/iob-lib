
VSRC+=iob_clkbuf.v
iob_clkbuf..v: $(LIB_DIR)/hardware/iob_clkbuf/iob_clkbuf.v
	cp $< $(BUILD_VSRC_DIR)

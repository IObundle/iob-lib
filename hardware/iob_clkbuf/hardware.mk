
VSRC+=$(BUILD_SRC_DIR)/iob_clkbuf.v
$(BUILD_SRC_DIR)/iob_clkbuf..v: $(LIB_DIR)/hardware/iob_clkbuf/iob_clkbuf.v
	cp $< $(BUILD_SRC_DIR)


VSRC+=iob2axil.v
iob2axil.v:$(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $(BUILD_VSRC_DIR)

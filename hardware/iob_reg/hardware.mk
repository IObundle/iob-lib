
VSRC+=iob_reg.v
iob_reg.v:$(LIB_DIR)/hardware/iob_reg/iob_reg.v
	cp $< $(BUILD_VSRC_DIR)

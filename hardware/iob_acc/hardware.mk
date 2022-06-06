
VSRC+=iob_acc.v
iob_acc.v:$(LIB_DIR)/hardware/iob_acc/iob_acc.v
	cp $< $(BUILD_VSRC_DIR)


VSRC+=$(BUILD_SRC_DIR)/iob_modcnt.v
$(BUILD_SRC_DIR)/iob_modcnt.v:$(LIB_DIR)/hardware/iob_modcnt/iob_modcnt.v
	cp $< $(BUILD_SRC_DIR)

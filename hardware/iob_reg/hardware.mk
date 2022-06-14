
VSRC+=$(BUILD_SRC_DIR)/iob_reg.v
$(BUILD_SRC_DIR)/iob_reg.v:$(LIB_DIR)/hardware/iob_reg/iob_reg.v
	cp $< $(BUILD_SRC_DIR)

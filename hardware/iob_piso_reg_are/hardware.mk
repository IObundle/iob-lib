
VSRC+=$(BUILD_SRC_DIR)/iob_piso_reg_are.v
$(BUILD_SRC_DIR)/iob_piso_reg_are.v:$(LIB_DIR)/hardware/iob_piso_reg_are/iob_piso_reg_are.v
	cp $< $(BUILD_SRC_DIR)

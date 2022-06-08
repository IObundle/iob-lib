
VSRC+=iob_piso_reg_are.v
iob_piso_reg_are.v:$(LIB_DIR)/hardware/iob_piso_reg_are/iob_piso_reg_are.v
	cp $< $(BUILD_DIR)/vsrc

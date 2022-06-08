VSRC+=iob_regfile_sp.v
iob_regfile_sp.v: $(LIB_DIR)/hardware/regfile/iob_regfile_sp/iob_regfile_sp.v
	cp $< $(BUILD_DIR)/vsrc

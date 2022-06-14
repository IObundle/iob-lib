VSRC+=$(BUILD_SRC_DIR)/iob_regfile_sp.v

$(BUILD_SRC_DIR)/iob_regfile_sp.v: hardware/regfile/iob_regfile_sp/iob_regfile_sp.v
	cp $< $(BUILD_SRC_DIR)

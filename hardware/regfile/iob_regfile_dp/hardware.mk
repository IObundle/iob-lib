
VSRC+=$(BUILD_SRC_DIR)/iob_regfile_dp.v

$(BUILD_SRC_DIR)/iob_regfile_dp.v:$(LIB_DIR)/hardware/regfile/iob_regfile_dp/iob_regfile_dp.v
	cp $< $(BUILD_SRC_DIR)

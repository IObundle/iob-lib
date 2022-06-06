
VSRC+=iob_ram_tdp.v
iob_ram_tdp.v:$(LIB_DIR)/hardware/ram/iob_ram_tdp/iob_ram_tdp.v
	cp $< $(BUILD_VSRC_DIR)

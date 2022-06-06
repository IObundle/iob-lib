VSRC+=iob_ram_sp.v
iob_ram_sp.v: $(LIB_DIR)/hardware/ram/iob_ram_sp/iob_ram_sp.v
	cp $< $(BUILD_VSRC_DIR)

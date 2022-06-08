
VSRC+=iob_ram_t2p.v
iob_ram_t2p.v:$(LIB_DIR)/hardware/ram/iob_ram_t2p/iob_ram_t2p.v
	cp $< $(BUILD_DIR)/vsrc

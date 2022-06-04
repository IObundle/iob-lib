include $(LIB_DIR)/hardware/ram/iob_ram_t2p/hardware.mk

VSRC+=iob_ram_t2p_asym.v
iob_ram_t2p_asym.v:$(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/iob_ram_t2p_asym.v
	cp $< .

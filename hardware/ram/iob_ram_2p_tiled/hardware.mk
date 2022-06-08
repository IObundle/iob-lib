include $(LIB_DIR)/hardware/ram/iob_ram_2p/hardware.mk

VSRC+=iob_ram_2p_tiled.v
iob_ram_2p_tiled.v:$(LIB_DIR)/hardware/ram/iob_ram_2p_tiled/iob_ram_2p_tiled.v
	cp $< $(BUILD_DIR)/vsrc

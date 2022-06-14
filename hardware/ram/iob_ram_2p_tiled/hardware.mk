include $(LIB_DIR)/hardware/ram/iob_ram_2p/hardware.mk

VSRC+=$(BUILD_SRC_DIR)/iob_ram_2p_tiled.v
$(BUILD_SRC_DIR)/iob_ram_2p_tiled.v:$(LIB_DIR)/hardware/ram/iob_ram_2p_tiled/iob_ram_2p_tiled.v
	cp $< $(BUILD_SRC_DIR)

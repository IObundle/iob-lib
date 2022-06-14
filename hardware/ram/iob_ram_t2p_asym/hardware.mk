include $(LIB_DIR)/hardware/ram/iob_ram_t2p/hardware.mk

VSRC+=$(BUILD_SRC_DIR)/iob_ram_t2p_asym.v
$(BUILD_SRC_DIR)/iob_ram_t2p_asym.v:$(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/iob_ram_t2p_asym.v
	cp $< $(BUILD_SRC_DIR)

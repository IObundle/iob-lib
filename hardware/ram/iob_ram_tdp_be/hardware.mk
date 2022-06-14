include $(LIB_DIR)/hardware/ram/iob_ram_tdp/hardware.mk

VSRC+=$(BUILD_SRC_DIR)/iob_ram_tdp_be.v
$(BUILD_SRC_DIR)/iob_ram_tdp_be.v:$(LIB_DIR)/hardware/ram/iob_ram_tdp_be/iob_ram_tdp_be.v
	cp $< $(BUILD_SRC_DIR)

include $(LIB_DIR)/hardware/ram/iob_ram_sp/hardware.mk

VSRC+=$(BUILD_SRC_DIR)/iob_ram_sp_be.v
$(BUILD_SRC_DIR)/iob_ram_sp_be.v:$(LIB_DIR)/hardware/ram/iob_ram_sp_be/iob_ram_sp_be.v
	cp $< $(BUILD_SRC_DIR)

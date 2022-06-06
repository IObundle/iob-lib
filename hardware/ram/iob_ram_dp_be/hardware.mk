include $(LIB_DIR)/hardware/ram/iob_ram_dp/hardware.mk

VSRC+=iob_ram_dp_be.v
iob_ram_dp_be.v:$(LIB_DIR)/hardware/ram/iob_ram_dp_be/iob_ram_dp_be.v
	cp $< $(BUILD_VSRC_DIR)

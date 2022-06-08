include $(LIB_DIR)/hardware/ram/iob_ram_sp/hardware.mk

VSRC+=iob_ram_sp_be.v
iob_ram_sp_be.v:$(LIB_DIR)/hardware/ram/iob_ram_sp_be/iob_ram_sp_be.v
	cp $< $(BUILD_DIR)/vsrc

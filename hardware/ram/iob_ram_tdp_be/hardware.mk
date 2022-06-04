include $(LIB_DIR)/hardware/ram/iob_ram_tdp/hardware.mk

VSRC+=iob_ram_tdp_be.v
iob_ram_tdp_be.v:$(LIB_DIR)/hardware/ram/iob_ram_tdp_be/iob_ram_tdp_be.v
	cp $< .

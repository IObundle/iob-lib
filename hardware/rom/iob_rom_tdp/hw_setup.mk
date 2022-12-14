ifeq ($(filter iob_rom_tdp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_rom_tdp

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_rom_tdp.v

# Copy souces to build directory
%/iob_rom_tdp.v: $(LIB_DIR)/hardware/rom/iob_rom_tdp/iob_rom_tdp.v
	cp $< $@

endif

ifeq ($(filter iob_rom_sp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_rom_sp

# Sources 
SRC+=$(BUILD_SIM_DIR)/src/iob_rom_sp.v

# Copy sources to build directory
%/iob_rom_sp.v: $(LIB_DIR)/hardware/rom/iob_rom_sp/iob_rom_sp.v
	cp $< $@

endif

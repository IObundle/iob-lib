ifeq ($(filter iob_rom_dp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_rom_dp

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_rom_dp.v

# Copy sources to build directory
$(BUILD_VSRC_DIR)/iob_rom_dp.v:hardware/rom/iob_rom_dp/iob_rom_dp.v
	cp $< $(BUILD_VSRC_DIR)

endif


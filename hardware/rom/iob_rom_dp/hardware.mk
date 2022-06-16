
ifeq ($(filter iob_rom_dp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_rom_dp

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_rom_dp.v

# Copy sources to build directory
$(BUILD_SRC_DIR)/iob_rom_dp.v:$(LIB_DIR)/hardware/rom/iob_rom_dp/iob_rom_dp.v
	cp $< $(BUILD_SRC_DIR)

endif


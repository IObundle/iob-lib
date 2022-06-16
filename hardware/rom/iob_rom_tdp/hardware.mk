
ifeq ($(filter iob_rom_tdp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_rom_tdp

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_rom_tdp.v

# Copy souces to build directory
$(BUILD_SRC_DIR)/iob_rom_tdp.v:$(LIB_DIR)/hardware/rom/iob_rom_tdp/iob_rom_tdp.v
	cp $< $(BUILD_SRC_DIR)

endif

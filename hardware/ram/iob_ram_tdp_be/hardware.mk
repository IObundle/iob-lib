
ifeq ($(filter iob_ram_tdp_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_tdp_be

# Submodules
include hardware/ram/iob_ram_tdp/hardware.mk

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_ram_tdp_be.v

# Copy the sources to the build directoy 
$(BUILD_VSRC_DIR)/iob_ram_tdp_be.v:hardware/ram/iob_ram_tdp_be/iob_ram_tdp_be.v
	cp $< $(BUILD_VSRC_DIR)

endif

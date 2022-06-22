ifeq ($(filter iob_ram_dp_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_dp_be

# Submodules
include hardware/ram/iob_ram_dp/hardware.mk

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_ram_dp_be.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_ram_dp_be.v:hardware/ram/iob_ram_dp_be/iob_ram_dp_be.v
	cp $< $(BUILD_VSRC_DIR)

endif

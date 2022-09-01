ifeq ($(filter iob_ram_dp_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_dp_be

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_dp/hardware.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_ram_dp_be.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_ram_dp_be.v: $(LIB_DIR)/hardware/ram/iob_ram_dp_be/iob_ram_dp_be.v
	cp $< $(BUILD_VSRC_DIR)

endif

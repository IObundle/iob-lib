ifeq ($(filter iob_ram_t2p_asym, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_t2p_asym

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_t2p/hardware.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_ram_t2p_asym.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_ram_t2p_asym.v: $(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/iob_ram_t2p_asym.v
	cp $< $(BUILD_VSRC_DIR)

endif

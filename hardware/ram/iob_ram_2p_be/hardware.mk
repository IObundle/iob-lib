ifeq ($(filter iob_ram_2p_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p_be

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_ram_2p_be.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_ram_2p_be.v: hardware/ram/iob_ram_2p_be/iob_ram_2p_be.v
	cp $< $(BUILD_VSRC_DIR)

endif

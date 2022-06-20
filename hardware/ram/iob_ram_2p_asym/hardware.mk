ifeq ($(filter iob_ram_2p_asym, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p_asym

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_ram_2p_asym.v

# Copy the sources to the buil;d directory
$(BUILD_SRC_DIR)/iob_ram_2p_asym.v: hardware/ram/iob_ram_2p_asym/iob_ram_2p_asym.v
	cp $< $(BUILD_SRC_DIR)

endif

ifeq ($(filter iob_ram_dp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_dp

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_ram_dp.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/iob_ram_dp.v:hardware/ram/iob_ram_dp/iob_ram_dp.v
	cp $< $(BUILD_SRC_DIR)

endif

ifeq ($(filter iob_ram_sp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_sp

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_ram_sp.v

# Copy sources to build directory
$(BUILD_VSRC_DIR)/iob_ram_sp.v: hardware/ram/iob_ram_sp/iob_ram_sp.v
	cp $< $(BUILD_VSRC_DIR)

endif

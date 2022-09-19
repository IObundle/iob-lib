ifeq ($(filter iob_ram_2p, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_ram_2p.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_ram_2p.v: $(LIB_DIR)/hardware/ram/iob_ram_2p/iob_ram_2p.v
	cp $< $(BUILD_VSRC_DIR)

endif

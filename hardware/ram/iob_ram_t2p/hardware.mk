
ifeq ($(filter iob_ram_t2p, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_t2p

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_ram_t2p.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/iob_ram_t2p.v:$(LIB_DIR)/hardware/ram/iob_ram_t2p/iob_ram_t2p.v
	cp $< $(BUILD_SRC_DIR)

endif


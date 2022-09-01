ifeq ($(filter iob_ram_2p_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p_be

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_ram_2p_be.v

# Copy sources to build directory 
$(BUILD_VSRC_DIR)/iob_ram_2p_be.v: $(LIB_DIR)/hardware/ram/iob_ram_2p_be/iob_ram_2p_be.v
	cp $< $(BUILD_VSRC_DIR)

endif

ifeq ($(filter iob_ram_2p_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p_be

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_2p_be.v

# Copy sources to build directory 
$(BUILD_SIM_DIR)/src/iob_ram_2p_be.v: $(LIB_DIR)/hardware/ram/iob_ram_2p_be/iob_ram_2p_be.v
	cp $< $@

endif

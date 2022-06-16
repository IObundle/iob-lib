
ifeq ($(filter iob_ram_sp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_sp

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_ram_sp.v

# Copy sources to build directory
$(BUILD_SRC_DIR)/iob_ram_sp.v: $(LIB_DIR)/hardware/ram/iob_ram_sp/iob_ram_sp.v
	cp $< $(BUILD_SRC_DIR)

endif

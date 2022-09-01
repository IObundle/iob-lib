ifeq ($(filter iob_clkmux, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_clkmux

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob_clkmux.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_clkmux.v: $(LIB_DIR)/hardware/iob_clkmux/iob_clkmux.v
	cp $< $(BUILD_VSRC_DIR)

endif

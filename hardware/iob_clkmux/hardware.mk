
ifneq (iob_clkmux,$(filter iob_clkmux, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_clkmux

# Sources 
VSRC+=$(BUILD_SRC_DIR)/iob_clkmux.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/iob_clkmux.v: $(LIB_DIR)/hardware/iob_clkmux/iob_clkmux.v
	cp $< $(BUILD_SRC_DIR)

endif

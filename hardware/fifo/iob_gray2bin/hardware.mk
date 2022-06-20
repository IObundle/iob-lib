
ifeq ($(filter iob_gray2bin, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_gray2bin

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_gray2bin.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/iob_gray2bin.v:hardware/fifo/iob_gray2bin/iob_gray2bin.v
	cp $< $(BUILD_SRC_DIR)

endif


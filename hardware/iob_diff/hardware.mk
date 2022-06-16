
ifeq ($(filter iob_diff, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_diff

# Sopurces
VSRC+=$(BUILD_SRC_DIR)/iob_diff.v

# Copy the sources to the build directoy
$(BUILD_SRC_DIR)/iob_diff.v:$(LIB_DIR)/hardware/iob_diff/iob_diff.v
	cp $< $(BUILD_SRC_DIR)

endif

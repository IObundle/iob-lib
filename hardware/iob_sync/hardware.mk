
ifneq (iob_sync,$(filter iob_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_sync

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_sync.v

# Copy sources to the build directory
$(BUILD_VSRC_DIR)/iob_sync.v:hardware/iob_sync/iob_sync.v
	cp $< $(BUILD_VSRC_DIR)

endif

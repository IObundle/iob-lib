
ifneq (iob_reset_sync,$(filter iob_reset_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reset_sync

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_reset_sync.v

# Copy the sources to the build directoy
$(BUILD_SRC_DIR)/iob_reset_sync.v:$(LIB_DIR)/hardware/iob_reset_sync/iob_reset_sync.v
	cp $< $(BUILD_SRC_DIR)

endif

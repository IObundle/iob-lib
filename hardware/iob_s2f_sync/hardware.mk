
ifeq ($(filter iob_s2f_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_s2f_sync

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_s2f_sync.v

# Copy the sources to the build directoy 
$(BUILD_SRC_DIR)/iob_s2f_sync.v:hardware/iob_s2f_sync/iob_s2f_sync.v
	cp $< $(BUILD_SRC_DIR)

endif

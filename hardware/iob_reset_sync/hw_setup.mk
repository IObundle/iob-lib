ifeq ($(filter iob_reset_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reset_sync

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reset_sync.v

# Copy the sources to the build directoy
$(BUILD_VSRC_DIR)/iob_reset_sync.v: $(LIB_DIR)/hardware/iob_reset_sync/iob_reset_sync.v
	cp $< $@

endif

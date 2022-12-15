ifeq ($(filter iob_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_sync

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_sync.v

# Copy sources to the build directory
$(BUILD_VSRC_DIR)/iob_sync.v: $(LIB_DIR)/hardware/iob_sync/iob_sync.v
	cp $< $@

endif

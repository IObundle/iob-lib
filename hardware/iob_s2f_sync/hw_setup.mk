ifeq ($(filter iob_s2f_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_s2f_sync

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_s2f_sync.v

# Copy the sources to the build directoy 
$(BUILD_VSRC_DIR)/iob_s2f_sync.v: $(LIB_DIR)/hardware/iob_s2f_sync/iob_s2f_sync.v
	cp $< $@

endif

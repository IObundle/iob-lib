ifeq ($(filter iob_modcnt, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_modcnt

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_modcnt.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_modcnt.v:hardware/iob_modcnt/iob_modcnt.v
	cp $< $(BUILD_VSRC_DIR)

endif

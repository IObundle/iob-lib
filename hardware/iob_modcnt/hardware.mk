
ifneq (iob_modcnt,$(filter iob_modcnt, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_modcnt

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_modcnt.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/iob_modcnt.v:hardware/iob_modcnt/iob_modcnt.v
	cp $< $(BUILD_SRC_DIR)

endif

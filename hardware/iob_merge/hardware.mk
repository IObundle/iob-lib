
ifneq (iob_merge,$(filter iob_merge, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_merge

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_merge.v

# Copy the sources to the build directoy
$(BUILD_VSRC_DIR)/iob_merge.v:hardware/iob_merge/iob_merge.v
	cp $< $(BUILD_VSRC_DIR)

endif

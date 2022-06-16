
ifneq (iob_merge,$(filter iob_merge, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_merge

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_merge.v

# Copy the sources to the build directoy
$(BUILD_SRC_DIR)/iob_merge.v:$(LIB_DIR)/hardware/iob_merge/iob_merge.v
	cp $< $(BUILD_SRC_DIR)

endif

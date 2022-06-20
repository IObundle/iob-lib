
ifneq (iob_split,$(filter iob_split, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_split

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_split.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/iob_split.v:hardware/iob_split/iob_split.v
	cp $< $(BUILD_SRC_DIR)

endif

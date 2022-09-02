ifeq ($(filter iob_split, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_split

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_split.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_split.v: $(LIB_DIR)/hardware/iob_split/iob_split.v
	cp $< $(BUILD_VSRC_DIR)

endif

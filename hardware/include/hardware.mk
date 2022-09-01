ifneq (include,$(filter include, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=include

# Sources
SRC+=$(BUILD_VSRC_DIR)/$(patsubst $(LIB_DIR)/hardware/include, $(BUILD_VSRC_DIR), $(wildcard $(LIB_DIR)/hardware/include/*.vh))

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/%.vh: $(LIB_DIR)/hardware/include/%.vh
	cp $< $(BUILD_VSRC_DIR)

endif

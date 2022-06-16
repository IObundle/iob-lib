
ifeq ($(filter iob_reverse, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reverse

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_reverse.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/iob_reverse.v:$(LIB_DIR)/hardware/iob_reverse/iob_reverse.v
	cp $< $(BUILD_SRC_DIR)

endif

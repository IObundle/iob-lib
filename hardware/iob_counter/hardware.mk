
ifeq ($(filter iob_counter, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_counter

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_counter.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/iob_counter.v:hardware/iob_counter/iob_counter.v
	cp $< $(BUILD_SRC_DIR)

endif

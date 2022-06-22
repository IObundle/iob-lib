
ifeq ($(filter iob_acc, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_acc

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_acc.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_acc.v:hardware/iob_acc/iob_acc.v
	cp $< $(BUILD_VSRC_DIR)

endif

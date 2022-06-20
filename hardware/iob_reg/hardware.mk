
ifeq ($(filter iob_reg, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_reg.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/iob_reg.v:hardware/iob_reg/iob_reg.v
	cp $< $(BUILD_SRC_DIR)

endif

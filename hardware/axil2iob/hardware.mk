
ifneq (axil2iob,$(filter axil2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil2iob

# Sources
VSRC+=$(BUILD_SRC_DIR)/axil2iob.v

# Copy the sources to the build directory
$(BUILD_SRC_DIR)/axil2iob.v:hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_SRC_DIR)

endif

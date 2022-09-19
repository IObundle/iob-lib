ifeq ($(filter axil2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil2iob

# Headers
SRC+=$(BUILD_VSRC_DIR)/iob_gen_if.vh
$(BUILD_VSRC_DIR)/iob_gen_if.vh: $(LIB_DIR)/hardware/include/iob_gen_if.vh
	cp $< $@

# Sources
SRC+=$(BUILD_VSRC_DIR)/axil2iob.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/axil2iob.v: $(LIB_DIR)/hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_VSRC_DIR)

endif

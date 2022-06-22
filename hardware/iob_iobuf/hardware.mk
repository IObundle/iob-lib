
ifneq (iob_iobuf,$(filter iob_iobuf, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_iobuf

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_iobuf.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_iobuf.v:hardware/iob_iobuf/iob_iobuf.v
	cp $< $(BUILD_VSRC_DIR)


endif

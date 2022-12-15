ifeq ($(filter iob_iobuf, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_iobuf

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_iobuf.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_iobuf.v: $(LIB_DIR)/hardware/iob_iobuf/iob_iobuf.v
	cp $< $@

endif

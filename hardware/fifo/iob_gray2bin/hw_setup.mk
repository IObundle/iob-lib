ifeq ($(filter iob_gray2bin, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_gray2bin

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_gray2bin.v

# Copy the sources to the build directory
%/iob_gray2bin.v: $(LIB_DIR)/hardware/fifo/iob_gray2bin/iob_gray2bin.v
	cp $< $@

endif


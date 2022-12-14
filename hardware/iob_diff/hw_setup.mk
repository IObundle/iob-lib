ifeq ($(filter iob_diff, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_diff

# Sopurces
SRC+=$(BUILD_VSRC_DIR)/iob_diff.v

# Copy the sources to the build directoy
%/iob_diff.v: $(LIB_DIR)/hardware/iob_diff/iob_diff.v
	cp $< $@

endif

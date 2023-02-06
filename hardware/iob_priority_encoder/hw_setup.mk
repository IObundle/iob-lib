ifeq ($(filter iob_priority_encoder, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_priority_encoder

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_priority_encoder.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_priority_encoder.v: $(LIB_DIR)/hardware/iob_priority_encoder/iob_priority_encoder.v
	cp $< $@

endif

ifneq (iob_pulse_gen,$(filter iob_pulse_gen, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_pulse_gen

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_pulse_gen.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_pulse_gen.v: hardware/iob_pulse_gen/iob_pulse_gen.v
	cp $< $(BUILD_VSRC_DIR)

endif

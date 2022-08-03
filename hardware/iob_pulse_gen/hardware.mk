ifneq (iob_pulse_gen,$(filter iob_pulse_gen, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_pulse_gen

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_pulse_gen/iob_pulse_gen.v

endif

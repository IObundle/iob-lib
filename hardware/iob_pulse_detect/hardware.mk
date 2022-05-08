ifneq (iob_pulse_detect,$(filter iob_pulse_detect, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_pulse_detect

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_pulse_detect/iob_pulse_detect.v

endif

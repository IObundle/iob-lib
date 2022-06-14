
VSRC+=$(BUILD_SRC_DIR)/iob_pulse_detect.v
$(BUILD_SRC_DIR)/iob_pulse_detect.v:$(LIB_DIR)/hardware/iob_pulse_detect/iob_pulse_detect.v
	cp $< $(BUILD_SRC_DIR)

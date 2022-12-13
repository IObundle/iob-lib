ifeq ($(filter iob_pulse_gen, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_pulse_gen

# Subcomponents
include $(LIB_DIR)/hardware/reg/iob_reg_ae/hw_setup.mk
include $(LIB_DIR)/hardware/counter/iob_counter/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_pulse_gen.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_pulse_gen.v: $(LIB_DIR)/hardware/iob_pulse_gen/iob_pulse_gen.v
	cp $< $@

endif

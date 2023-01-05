ifeq ($(filter iob_sipo_reg, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_sipo_reg

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_sipo_reg.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_sipo_reg.v: $(LIB_DIR)/hardware/iob_sipo_reg/iob_sipo_reg.v
	cp $< $@

endif

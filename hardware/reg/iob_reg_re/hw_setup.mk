ifeq ($(filter iob_reg_re, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_re

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg_r/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_re.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_re.v: $(LIB_DIR)/hardware/reg/iob_reg_re/iob_reg_re.v
	cp $< $@

endif

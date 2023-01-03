ifeq ($(filter iob_reg_e, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_e

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_e.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_e.v: $(LIB_DIR)/hardware/reg/iob_reg_e/iob_reg_e.v
	cp $< $@

endif

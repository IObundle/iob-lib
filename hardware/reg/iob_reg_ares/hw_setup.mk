ifeq ($(filter iob_reg_ares, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_ares

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg_are/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_ares.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_ares.v: $(LIB_DIR)/hardware/reg/iob_reg_ares/iob_reg_ares.v
	cp $< $@

endif

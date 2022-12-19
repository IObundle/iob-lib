ifeq ($(filter iob_reg_aes, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_aes

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg_ae/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_aes.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_aes.v: $(LIB_DIR)/hardware/reg/iob_reg_aes/iob_reg_aes.v
	cp $< $@

endif

ifeq ($(filter iob_reg_n_aes, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_n_aes

# Submodules
include $(LIB_DIR)/hardware/reg_n/iob_reg_n_ae/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_n_aes.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_n_aes.v: $(LIB_DIR)/hardware/reg_n/iob_reg_n_aes/iob_reg_n_aes.v
	cp $< $@

endif

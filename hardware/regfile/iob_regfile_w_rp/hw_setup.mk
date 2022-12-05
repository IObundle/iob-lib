ifeq ($(filter iob_regfile_w_rp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_regfile_w_rp

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg_are/hw_setup.mk

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob_regfile_w_rp.v

# Copy the sources to build directory
$(BUILD_VSRC_DIR)/iob_regfile_w_rp.v: $(LIB_DIR)/hardware/regfile/iob_regfile_w_rp/iob_regfile_w_rp.v
	cp $< $(BUILD_VSRC_DIR)

endif

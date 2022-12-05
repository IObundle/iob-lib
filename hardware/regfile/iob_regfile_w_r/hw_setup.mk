ifeq ($(filter iob_regfile_w_r, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_regfile_w_r

# Submodules
include $(LIB_DIR)/hardware/iob_reg/hw_setup.mk

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob_regfile_w_r.v

# Copy the sources to build directory
$(BUILD_VSRC_DIR)/iob_regfile_w_r.v: $(LIB_DIR)/hardware/regfile/iob_regfile_w_r/iob_regfile_w_r.v
	cp $< $(BUILD_VSRC_DIR)

endif

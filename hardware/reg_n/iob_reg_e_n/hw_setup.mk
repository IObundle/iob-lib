ifeq ($(filter iob_reg_e_n, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reg_e_n

# Submodules
include $(LIB_DIR)/hardware/reg_n/iob_reg_n/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_reg_e_n.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_reg_e_n.v: $(LIB_DIR)/hardware/reg_n/iob_reg_e_n/iob_reg_e_n.v
	cp $< $@

endif

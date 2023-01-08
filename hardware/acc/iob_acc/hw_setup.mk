ifeq ($(filter iob_acc, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_acc

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg_re/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_acc.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_acc.v: $(LIB_DIR)/hardware/acc/iob_acc/iob_acc.v
	cp $< $@

endif

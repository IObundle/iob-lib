ifeq ($(filter iob_modcnt, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_modcnt

# Submodules
include $(LIB_DIR)/hardware/iob_counter/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_modcnt.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_modcnt.v: $(LIB_DIR)/hardware/iob_modcnt/iob_modcnt.v
	cp $< $(BUILD_VSRC_DIR)

endif

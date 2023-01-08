ifeq ($(filter iob_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_sync

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_sync.v

# Copy sources to the build directory
$(BUILD_VSRC_DIR)/iob_sync.v: $(LIB_DIR)/hardware/iob_sync/iob_sync.v
	cp $< $@

endif

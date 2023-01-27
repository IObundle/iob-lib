ifeq ($(filter iob_reset_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reset_sync

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_reset_sync.v

# Copy the sources to the build directoy
%/iob_reset_sync.v: $(LIB_DIR)/hardware/iob_reset_sync/iob_reset_sync.v
	cp $< $@

endif

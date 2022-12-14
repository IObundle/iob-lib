ifeq ($(filter iob_modcnt_ld, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_modcnt_ld

# Submodules
include $(LIB_DIR)/hardware/counter/iob_counter_ld/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_modcnt_ld.v

# Copy the sources to the build directory 
%/iob_modcnt_ld.v: $(LIB_DIR)/hardware/modcnt/iob_modcnt_ld/iob_modcnt_ld.v
	cp $< $@

endif

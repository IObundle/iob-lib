ifeq ($(filter iob_modcnt_en, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_modcnt_en

# Submodules
include $(LIB_DIR)/hardware/counter/iob_counter_en/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_modcnt_en.v

# Copy the sources to the build directory 

$(BUILD_VSRC_DIR)/iob_modcnt_en.v: $(LIB_DIR)/hardware/modcnt/iob_modcnt_en/iob_modcnt_en.v
	cp $< $@

endif

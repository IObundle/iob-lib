ifeq ($(filter iob_modcnt_en_ld_n, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_modcnt_en_ld_n

# Submodules
include $(LIB_DIR)/hardware/counter/iob_counter_en_ld_n/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_modcnt_en_ld_n.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_modcnt_en_ld_n.v: $(LIB_DIR)/hardware/modcnt/iob_modcnt_en_ld_n/iob_modcnt_en_ld_n.v
	cp $< $@

endif

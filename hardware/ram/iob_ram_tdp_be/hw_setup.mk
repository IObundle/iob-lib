ifeq ($(filter iob_ram_tdp_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_tdp_be

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_tdp/hw_setup.mk

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_tdp_be.v

# Copy the sources to the build directoy 
$(BUILD_SIM_DIR)/src/iob_ram_tdp_be.v: $(LIB_DIR)/hardware/ram/iob_ram_tdp_be/iob_ram_tdp_be.v
	cp $< $@

endif

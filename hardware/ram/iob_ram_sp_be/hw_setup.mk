ifeq ($(filter iob_ram_sp_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_sp_be

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_sp/hw_setup.mk

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_sp_be.v

# Copy the sources to the build directory 
$(BUILD_SIM_DIR)/src/iob_ram_sp_be.v: $(LIB_DIR)/hardware/ram/iob_ram_sp_be/iob_ram_sp_be.v
	cp $< $@

endif

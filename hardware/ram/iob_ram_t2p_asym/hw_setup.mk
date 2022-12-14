ifeq ($(filter iob_ram_t2p_asym, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_t2p_asym

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_t2p/hw_setup.mk

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_t2p_asym.v

# Copy the sources to the build directory
%/iob_ram_t2p_asym.v: $(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/iob_ram_t2p_asym.v
	cp $< $@

endif

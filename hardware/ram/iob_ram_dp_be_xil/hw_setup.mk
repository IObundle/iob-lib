ifeq ($(filter iob_ram_dp_be_xil, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_dp_be_xil

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_dp/hw_setup.mk

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_dp_be_xil.v

# Copy the sources to the build directory 
$(BUILD_SIM_DIR)/src/iob_ram_dp_be_xil.v: $(LIB_DIR)/hardware/ram/iob_ram_dp_be_xil/iob_ram_dp_be_xil.v
	cp $< $@

endif

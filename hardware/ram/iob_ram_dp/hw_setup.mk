ifeq ($(filter iob_ram_dp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_dp

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_dp.v

# Copy the sources to the build directory
%/iob_ram_dp.v: $(LIB_DIR)/hardware/ram/iob_ram_dp/iob_ram_dp.v
	cp $< $@

endif

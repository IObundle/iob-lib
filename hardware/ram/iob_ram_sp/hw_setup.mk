ifeq ($(filter iob_ram_sp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_sp

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_ram_sp.v

# Copy sources to build directory
%/iob_ram_sp.v: $(LIB_DIR)/hardware/ram/iob_ram_sp/iob_ram_sp.v
	cp $< $@

endif

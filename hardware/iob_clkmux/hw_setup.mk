ifeq ($(filter iob_clkmux, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_clkmux

# Sources 
SRC+=$(BUILD_SIM_DIR)/src/iob_clkmux.v

# Copy the sources to the build directory
%/iob_clkmux.v: $(LIB_DIR)/hardware/iob_clkmux/iob_clkmux.v
	cp $< $@

endif

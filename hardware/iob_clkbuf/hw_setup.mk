ifeq ($(filter iob_clkbuf, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_clkbuf

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_clkbuf.v

# Copy the sources to the build directoy 
%/iob_clkbuf.v: $(LIB_DIR)/hardware/iob_clkbuf/iob_clkbuf.v
	cp $< $@

endif


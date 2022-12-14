ifeq ($(filter iob_counter_ld, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_counter_ld

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_counter_ld.v

# Copy the sources to the build directory 
%/iob_counter_ld.v: $(LIB_DIR)/hardware/counter/iob_counter_ld/iob_counter_ld.v
	cp $< $@

endif

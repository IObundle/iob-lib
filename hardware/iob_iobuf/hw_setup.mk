ifeq ($(filter iob_iobuf, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_iobuf

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob_iobuf.v

# Copy the sources to the build directory 
%/iob_iobuf.v: $(LIB_DIR)/hardware/iob_iobuf/iob_iobuf.v
	cp $< $@

endif

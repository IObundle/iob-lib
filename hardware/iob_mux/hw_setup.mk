ifeq ($(filter iob_mux, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_mux

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_mux.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_mux.v: $(LIB_DIR)/hardware/iob_mux/iob_mux.v
	cp $< $(BUILD_VSRC_DIR)

endif

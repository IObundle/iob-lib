ifeq ($(filter iob_regfile_async_w_rr, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_regfile_async_w_rr

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob_regfile_async_w_rr.v

# Copy the sources to build directory
$(BUILD_VSRC_DIR)/iob_regfile_async_w_rr.v: $(LIB_DIR)/hardware/regfile/iob_regfile_async_w_rr/iob_regfile_async_w_rr.v
	cp $< $(BUILD_VSRC_DIR)

endif

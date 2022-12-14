ifeq ($(filter iob_regfile_sp, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_regfile_sp

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_regfile_sp.v

# Copy sources to build directory
%/iob_regfile_sp.v: $(LIB_DIR)/hardware/regfile/iob_regfile_sp/iob_regfile_sp.v
	cp $< $@

endif

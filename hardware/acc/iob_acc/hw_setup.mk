ifeq ($(filter iob_acc, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_acc

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_acc.v

# Copy the sources to the build directory 
%/iob_acc.v: $(LIB_DIR)/hardware/acc/iob_acc/iob_acc.v
	cp $< $@

endif

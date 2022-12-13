ifeq ($(filter iob_acc_ld, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_acc_ld

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_acc_ld.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_acc_ld.v: $(LIB_DIR)/hardware/acc/iob_acc_ld/iob_acc_ld.v
	cp $< $@

endif

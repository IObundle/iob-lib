ifeq ($(filter iob_acc_en, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_acc_en

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_acc_en.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_acc_en.v: $(LIB_DIR)/hardware/acc/iob_acc_en/iob_acc_en.v
	cp $< $@

endif

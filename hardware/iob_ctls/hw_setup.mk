ifeq ($(filter iob_ctls, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ctls

# Submodules
include $(LIB_DIR)/hardware/iob_reverse/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_ctls.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_ctls.v: $(LIB_DIR)/hardware/iob_ctls/iob_ctls.v
	cp $< $@

endif

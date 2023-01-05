ifeq ($(filter iob_edge_detect, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_edge_detect

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_edge_detect.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_edge_detect.v: $(LIB_DIR)/hardware/iob_edge_detect/iob_edge_detect.v
	cp $< $@

endif

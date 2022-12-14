ifeq ($(filter iob_gray_counter, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_gray_counter

#submodules
include $(LIB_DIR)/hardware/reg/iob_reg_are/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_gray_counter.v

# Copy the sources to the build directory
%/iob_gray_counter.v: $(LIB_DIR)/hardware/fifo/iob_gray_counter/iob_gray_counter.v
	cp $< $@

endif

ifeq ($(filter iob_fifo_async, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_fifo_async

# Submodules
include $(LIB_DIR)/hardware/iob_sync/hw_setup.mk
include $(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/hw_setup.mk
include $(LIB_DIR)/hardware/fifo/iob_gray_counter/hw_setup.mk
include $(LIB_DIR)/hardware/fifo/iob_gray2bin/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_fifo_async.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_fifo_async.v: $(LIB_DIR)/hardware/fifo/iob_fifo_async/iob_fifo_async.v
	cp $< $@

endif

ifeq ($(filter iob_fifo_async, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_fifo_async

# Submodules
include hardware/ram/iob_ram_t2p_asym/hardware.mk
include hardware/fifo/iob_gray_counter/hardware.mk
include hardware/fifo/iob_gray2bin/hardware.mk

# Sources
VSRC+=$(BUILD_VSRC_DIR)/iob_fifo_async.v

# Copy the sources to the build directory
$(BUILD_VSRC_DIR)/iob_fifo_async.v:hardware/fifo/iob_fifo_async/iob_fifo_async.v
	cp $< $(BUILD_VSRC_DIR)

endif



ifeq ($(filter iob_fifo_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_fifo_sync

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_2p_asym/hardware.mk

# Sources
VSRC+=$(BUILD_SRC_DIR)/iob_fifo_sync.v

# Copy the sources to the build directory 
$(BUILD_SRC_DIR)/iob_fifo_sync.v: $(LIB_DIR)/hardware/fifo/iob_fifo_sync/iob_fifo_sync.v
	cp $< $(BUILD_SRC_DIR)

endif

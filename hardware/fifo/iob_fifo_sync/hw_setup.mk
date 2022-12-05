ifeq ($(filter iob_fifo_sync, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_fifo_sync

# Submodules
include $(LIB_DIR)/hardware/reg/iob_reg_ar/hw_setup.mk
include $(LIB_DIR)/hardware/reg/iob_reg_ar/hw_setup.mk
include $(LIB_DIR)/hardware/iob_counter/hw_setup.mk
include $(LIB_DIR)/hardware/ram/iob_ram_2p_asym/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_fifo_sync.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_fifo_sync.v: $(LIB_DIR)/hardware/fifo/iob_fifo_sync/iob_fifo_sync.v
	cp $< $(BUILD_VSRC_DIR)

endif

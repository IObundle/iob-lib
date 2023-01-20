ifeq ($(filter iob_fifo_async, $(HW_MODULES)),)

# Submodules
include $(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/hw_setup.mk

endif

include $(LIB_DIR)/hardware/ram/iob_ram_2p_asym/hardware.mk

VSRC+=$(BUILD_SRC_DIR)/iob_fifo_sync.v
$(BUILD_SRC_DIR)/iob_fifo_sync.v: $(LIB_DIR)/hardware/fifo/iob_fifo_sync/iob_fifo_sync.v
	cp $< $(BUILD_SRC_DIR)

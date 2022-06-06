include $(LIB_DIR)/hardware/ram/iob_ram_t2p_asym/hardware.mk
include $(LIB_DIR)/hardware/fifo/iob_gray_counter/hardware.mk
include $(LIB_DIR)/hardware/fifo/iob_gray2bin/hardware.mk

VSRC+=iob_fifo_async.v
iob_fifo_async.v:$(LIB_DIR)/hardware/fifo/iob_fifo_async/iob_fifo_async.v
	cp $< $(BUILD_VSRC_DIR) 

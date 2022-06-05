
VSRC+=iob_fifo_sync.v
iob_fifo_sync.v: $(LIB_DIR)/hardware/fifo/iob_fifo_sync/iob_fifo_sync.v
	cp $< .

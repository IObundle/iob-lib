ifneq (iob2axi,$(filter iob2axi, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob2axi


include hardware/fifo/iob_fifo_sync/hardware.mk

# SRC+=m_axi_m_port.vh \
# m_axi_write_m_port.vh \
# m_axi_read_m_port.vh \
# m_m_axi_write_portmap.vh \
# m_m_axi_read_portmap.vh

SRC+=$(BUILD_VSRC_DIR)/iob2axi.v $(BUILD_VSRC_DIR)/iobwaxi_wr.v $(BUILD_VSRC_DIR)/iob2axi_rd.v

$(BUILD_VSRC_DIR)/iob2axi.v: hardware/iob2axi/iob2axi.v
	cp $< $(BUILD_VSRC_DIR)


$(BUILD_VSRC_DIR)/iobwaxi_wr.v: hardware/iob2axi/iob2axi_wr.v
	cp $< $(BUILD_VSRC_DIR)

$(BUILD_VSRC_DIR)/iob2axi_rd.v: hardware/iob2axi/iob2axi_rd.v
	cp $< $(BUILD_VSRC_DIR)


m_axi_m_port.vh:
	$(AXI_GEN) axi_m_port AXI_ADDR_W AXI_DATA_W 'm_'

m_axi_write_m_port.vh:
	$(AXI_GEN) axi_write_m_port AXI_ADDR_W AXI_DATA_W 'm_'

m_axi_read_m_port.vh:
	$(AXI_GEN) axi_read_m_port AXI_ADDR_W AXI_DATA_W 'm_'

m_m_axi_write_portmap.vh:
	$(AXI_GEN) axi_write_portmap AXI_ADDR_W AXI_DATA_W 'm_' 'm_'

m_m_axi_read_portmap.vh:
	$(AXI_GEN) axi_read_portmap AXI_ADDR_W AXI_DATA_W 'm_' 'm_'


endif

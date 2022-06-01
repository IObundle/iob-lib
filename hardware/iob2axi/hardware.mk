ifneq (iob2axi,$(filter iob2axi, $(HW_MODULES)))

include $(AXI_DIR)/config.mk

# Add to modules list
HW_MODULES+=iob2axi

# Submodules
include $(MEM_DIR)/hardware/fifo/iob_fifo_sync/hardware.mk

# Includes
INCLUDE+=$(incdir). $(incdir)$(AXI_DIR)/hardware/include

# Headers
VHDR+=m_axi_m_port.vh \
m_axi_write_m_port.vh \
m_axi_read_m_port.vh \
m_m_axi_write_portmap.vh \
m_m_axi_read_portmap.vh

# Sources
VSRC+=$(AXI_DIR)/hardware/iob2axi/iob2axi.v \
$(AXI_DIR)/hardware/iob2axi/iob2axi_wr.v \
$(AXI_DIR)/hardware/iob2axi/iob2axi_rd.v

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

ifneq (axis2axi,$(filter axis2axi, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=axis2axi

# Includes
INCLUDE+=$(incdir). $(incdir)$(AXI_DIR)/hardware/include

# Headers
THIS_VHDR := m_axi_m_port.vh \
m_axi_write_m_port.vh \
m_axi_read_m_port.vh \
m_axi_write_portmap.vh \
m_axi_read_portmap.vh

VHDR+= $(THIS_VHDR)

VSRC+=$(LIB_DIR)/hardware/modules/fifo/iob_fifo_sync/iob_fifo_sync.v
VSRC+=$(LIB_DIR)/hardware/modules/axis2axi/axis2axi.v \
$(LIB_DIR)/hardware/modules/axis2axi/axis2axi_in.v \
$(LIB_DIR)/hardware/modules/axis2axi/axis2axi_out.v

m_axi_m_port.vh:
	$(AXI_GEN) axi_m_port 'm_' 'm_'

m_axi_write_m_port.vh:
	$(AXI_GEN) axi_write_m_port 'm_' 'm_'

m_axi_read_m_port.vh:
	$(AXI_GEN) axi_read_m_port 'm_' 'm_'

m_axi_write_portmap.vh:
	$(AXI_GEN) axi_write_portmap 'm_' 'm_' 'm_'

m_axi_read_portmap.vh:
	$(AXI_GEN) axi_read_portmap 'm_' 'm_' 'm_'

endif
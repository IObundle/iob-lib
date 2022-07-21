ifneq (axi2axi,$(filter axi2axi, $(HW_MODULES)))

include $(AXI_DIR)/config.mk

# Add to modules list
HW_MODULES+=axi2axi

# Includes
INCLUDE+=$(incdir). $(incdir)$(AXI_DIR)/hardware/include

# Headers
VHDR+=s_axi_s_port.vh m_axi_m_port.vh

# Sources
VSRC+=$(AXI_DIR)/hardware/axi2axi/axi2axi.v

s_axi_s_port.vh:
	$(AXI_GEN) axi_m_port 's_' 's_'

m_axi_m_port.vh:
	$(AXI_GEN) axi_m_port 'm_' 'm_'

endif

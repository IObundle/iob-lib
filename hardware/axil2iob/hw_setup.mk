ifeq ($(filter axil2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil2iob

# import lib hardware
include $(LIB_DIR)/hardware/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/axil2iob.v
$(BUILD_VSRC_DIR)/axil2iob.v: $(LIB_DIR)/hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_VSRC_DIR)

# axil slave port
SRC+=$(BUILD_VSRC_DIR)/axil_s_port.vh
$(BUILD_VSRC_DIR)/axil_s_port.vh: axil_s_port.vh
	cp $< $@
axil_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_s_port '' ''

# axil slave portmap
SRC+=$(BUILD_VSRC_DIR)/axil_s_s_portmap.vh
$(BUILD_VSRC_DIR)/axil_s_s_portmap.vh: axil_s_s_portmap.vh
	cp $< $@
axil_s_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_s_s_portmap '' ''


# iob master port
SRC+=$(BUILD_VSRC_DIR)/iob_m_port.vh
$(BUILD_VSRC_DIR)/iob_m_port.vh: iob_m_port.vh
	cp $< $@
iob_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_port '' ''

#iob master portmap
SRC+=$(BUILD_VSRC_DIR)/iob_m_portmap.vh
$(BUILD_VSRC_DIR)/iob_m_portmap.vh: iob_m_portmap.vh
	cp $< $@
iob_m_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_portmap '' ''

# iob wires to drive swreg instance
SRC+=$(BUILD_SIM_DIR)/iob_wire.vh
$(BUILD_SIM_DIR)/iob_wire.vh: iob_wire.vh
	cp $< $@
iob_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_wire ''

endif

ifeq ($(filter iob2axil, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2axil

# import lib hardware
include $(LIB_DIR)/hardware/include/hw_setup.mk

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob2axil.v
$(BUILD_VSRC_DIR)/iob2axil.v: $(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $(BUILD_VSRC_DIR)

# iob slave port module
SRC+=$(BUILD_VSRC_DIR)/iob_s_port.vh
$(BUILD_VSRC_DIR)/iob_s_port.vh: iob_s_port.vh
	cp $< $@
iob_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_port '' ''


#iob slave portmap for instance
SRC+=$(BUILD_VSRC_DIR)/iob_s_portmap.vh
$(BUILD_VSRC_DIR)/iob_s_portmap.vh: iob_s_portmap.vh
	cp $< $@
iob_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_portmap '' '' ''


# axil master port
SRC+=$(BUILD_VSRC_DIR)/axil_m_port.vh
$(BUILD_VSRC_DIR)/axil_m_port.vh: axil_m_port.vh
	cp $< $@
axil_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_m_port '' ''

# axil master portmap for instance
SRC+=$(BUILD_VSRC_DIR)/axil_m_portmap.vh
$(BUILD_VSRC_DIR)/axil_m_portmap.vh: axil_m_portmap.vh
	cp $< $@
axil_m_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_m_portmap '' '' ''

# iob testbench signals to drive the wrapper
SRC+=$(BUILD_SIM_DIR)/iob_m_tb_wire.vh
$(BUILD_SIM_DIR)/iob_m_tb_wire.vh: iob_m_tb_wire.vh
	cp $< $@
iob_m_tb_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_tb_wire ''

#axil wires for portmap
SRC+=$(BUILD_VSRC_DIR)/axil_wire.vh
$(BUILD_VSRC_DIR)/axil_wire.vh: axil_wire.vh
	cp $< $@
axil_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_wire '' ''

endif

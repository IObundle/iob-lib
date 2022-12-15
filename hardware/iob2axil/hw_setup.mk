ifeq ($(filter iob2axil, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2axil

# import lib hardware
include $(LIB_DIR)/hardware/include/hw_setup.mk

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob2axil.v
$(BUILD_VSRC_DIR)/iob2axil.v: $(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $@

# iob slave port module
SRC+=$(BUILD_VSRC_DIR)/iob_s_port.vh
%/iob_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_port '$(@D)/' ''

# iob slave portmap for instance
SRC+=$(BUILD_VSRC_DIR)/iob_s_s_portmap.vh
%/iob_s_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_s_portmap '$(@D)/' '' ''

# axil master port
SRC+=$(BUILD_VSRC_DIR)/axil_m_port.vh
%/axil_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_m_port '$(@D)/' ''

# axil master portmap for instance
SRC+=$(BUILD_VSRC_DIR)/axil_m_portmap.vh
%/axil_m_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_m_portmap '$(@D)/' '' ''

# iob wires for testbench
SRC+=$(BUILD_SIM_DIR)/src/iob_m_tb_wire.vh
%/iob_m_tb_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_tb_wire '$(@D)/'

# axil wires for instance portmap
SRC+=$(BUILD_VSRC_DIR)/axil_wire.vh
%/axil_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_wire '$(@D)/' ''

endif

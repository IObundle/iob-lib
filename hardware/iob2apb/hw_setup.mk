ifeq ($(filter iob2apb, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2apb

# import lib hardware
include $(LIB_DIR)/hardware/include/hw_setup.mk
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob2apb.v
$(BUILD_VSRC_DIR)/iob2apb.v: $(LIB_DIR)/hardware/iob2apb/iob2apb.v
	cp $< $@

# iob slave port module
SRC+=$(BUILD_VSRC_DIR)/iob_s_port.vh
%/iob_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_port '$(@D)/' ''

# iob slave portmap for instance
SRC+=$(BUILD_VSRC_DIR)/iob_s_s_portmap.vh
%/iob_s_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_s_portmap '$(@D)/' '' ''

# apb master port
SRC+=$(BUILD_VSRC_DIR)/apb_m_port.vh
%/apb_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py apb_m_port '$(@D)/' ''

# apb master portmap for instance
SRC+=$(BUILD_VSRC_DIR)/apb_m_portmap.vh
%/apb_m_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py apb_m_portmap '$(@D)/' '' ''

# iob wires for testbench
SRC+=$(BUILD_SIM_DIR)/src/iob_m_tb_wire.vh
%/iob_m_tb_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_tb_wire '$(@D)/'

# apb wires for instance portmap
SRC+=$(BUILD_VSRC_DIR)/apb_wire.vh
%/apb_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py apb_wire '$(@D)/' ''

endif

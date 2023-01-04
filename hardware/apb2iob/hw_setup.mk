ifeq ($(filter apb2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=apb2iob

# import lib hardware
include $(LIB_DIR)/hardware/include/hw_setup.mk
include $(LIB_DIR)/hardware/reg/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/apb2iob.v
$(BUILD_VSRC_DIR)/apb2iob.v: $(LIB_DIR)/hardware/apb2iob/apb2iob.v
	cp $< $@

# APB slave port
SRC+=$(BUILD_VSRC_DIR)/apb_s_port.vh
%/apb_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py apb_s_port '$(@D)/' ''

# APB slave portmap for instance
SRC+=$(BUILD_VSRC_DIR)/apb_s_s_portmap.vh
%/apb_s_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py apb_s_s_portmap '$(@D)/' ''

# iob master port
SRC+=$(BUILD_VSRC_DIR)/iob_m_port.vh
$(BUILD_VSRC_DIR)/iob_m_port.vh: $(LIB_DIR)/hardware/apb2iob/iob_m_port.vh
	cp $< $@

#iob master portmap for instance
SRC+=$(BUILD_VSRC_DIR)/iob_m_portmap.vh
$(BUILD_VSRC_DIR)/iob_m_portmap.vh: $(LIB_DIR)/hardware/apb2iob/iob_m_portmap.vh
	cp $< $@

# iob wires to drive swreg instance
SRC+=$(BUILD_VSRC_DIR)/iob_wire.vh
%/iob_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_wire '$(@D)/'

#iob slave portmap for swreg instance
SRC+=$(BUILD_VSRC_DIR)/iob_s_portmap.vh
%/iob_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_portmap '$(@D)/' ''

endif

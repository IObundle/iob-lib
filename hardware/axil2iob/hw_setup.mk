ifeq ($(filter axil2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil2iob

# Sources
SRC+=$(BUILD_VSRC_DIR)/axil2iob.v
$(BUILD_VSRC_DIR)/axil2iob.v: $(LIB_DIR)/hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_VSRC_DIR)

# axil slave port
SRC+=$(BUILD_VSRC_DIR)/axil_s_port.vh
%/axil_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_s_port '$(@D)/' ''

# axil slave portmap for instance
SRC+=$(BUILD_VSRC_DIR)/axil_s_s_portmap.vh
%/axil_s_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_s_s_portmap '$(@D)/' ''


# iob master port
SRC+=$(BUILD_VSRC_DIR)/iob_m_port.vh
%/iob_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_port '$(@D)/' ''

#iob master portmap for instance
SRC+=$(BUILD_VSRC_DIR)/iob_m_portmap.vh
%/iob_m_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_m_portmap '$(@D)/' ''

# iob wires to drive swreg instance
SRC+=$(BUILD_VSRC_DIR)/iob_wire.vh
%/iob_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_wire '$(@D)/'

#iob slave portmap for swreg instance
SRC+=$(BUILD_VSRC_DIR)/iob_s_portmap.vh
%/iob_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_portmap '$(@D)/' ''

endif

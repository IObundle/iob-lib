ifeq ($(filter iob2axil, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2axil

# import lib hardware
include $(LIB_DIR)/hardware/include/hw_setup.mk

# Sources 
SRC+=$(BUILD_VSRC_DIR)/iob2axil.v
$(BUILD_VSRC_DIR)/iob2axil.v: $(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $(BUILD_VSRC_DIR)

# AXI4 Lite master port
SRC+=$(BUILD_VSRC_DIR)/axil_m_port.vh
$(BUILD_VSRC_DIR)/axil_m_port.vh: axil_m_port.vh
	cp $< $@
axil_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py axil_m_port '' ''

# iob slave port
SRC+=$(BUILD_VSRC_DIR)/iob_s_port.vh
$(BUILD_VSRC_DIR)/iob_s_port.vh: iob_s_port.vh
	cp $< $@
iob_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_port '' ''

endif

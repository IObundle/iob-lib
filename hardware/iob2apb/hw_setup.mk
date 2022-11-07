ifeq ($(filter iob2apb, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2apb

# import lib hardware
include $(LIB_DIR)/hardware/include/hw_setup.mk
include $(LIB_DIR)/hardware/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob2apb.v
$(BUILD_VSRC_DIR)/iob2apb.v: $(LIB_DIR)/hardware/iob2apb/iob2apb.v
	cp $< $(BUILD_VSRC_DIR)

# APB master port
SRC+=$(BUILD_VSRC_DIR)/apb_m_port.vh
$(BUILD_VSRC_DIR)/apb_m_port.vh: apb_m_port.vh
	cp $< $@
apb_m_port.vh:
	$(LIB_DIR)/scripts/if_gen.py apb_m_port '' ''

# iob slave port
SRC+=$(BUILD_VSRC_DIR)/iob_s_port.vh
$(BUILD_VSRC_DIR)/iob_s_port.vh: iob_s_port.vh
	cp $< $@
iob_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_port '' ''

endif

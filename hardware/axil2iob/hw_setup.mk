ifeq ($(filter axil2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil2iob

# Headers
SRC+=$(BUILD_VSRC_DIR)/iob_gen_if.vh
$(BUILD_VSRC_DIR)/iob_gen_if.vh: $(LIB_DIR)/hardware/include/iob_gen_if.vh
	cp $< $@

# Sources
SRC+=$(BUILD_VSRC_DIR)/axil2iob.v
$(BUILD_VSRC_DIR)/axil2iob.v: $(LIB_DIR)/hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_VSRC_DIR)

#axil slave port
SRC+=$(BUILD_VSRC_DIR)/iob_axil_s_port.vh
$(BUILD_VSRC_DIR)/iob_axil_s_port.vh: iob_axil_s_port.vh
	cp $< $@
iob_axil_s_port.vh:
	$(LIB_DIR)/scripts/axi_gen.py axil_s_port 'iob_' ''

#axil portmap
SRC+=$(BUILD_VSRC_DIR)/iob_axi_portmap.vh
$(BUILD_VSRC_DIR)/iob_axi_portmap.vh: iob_axi_portmap.vh
	cp $< $@
iob_axi_portmap.vh:
	$(LIB_DIR)/scripts/axi_gen.py axi_portmap 'iob_' '' ''

#iob master port
SRC+=$(BUILD_VSRC_DIR)/iob_m_port.vh
$(BUILD_VSRC_DIR)/iob_m_port.vh: $(LIB_DIR)/hardware/include/iob_m_port.vh
	cp $< $@

#iob master portmap
SRC+=$(BUILD_VSRC_DIR)/iob_portmap.vh
$(BUILD_VSRC_DIR)/iob_portmap.vh: $(LIB_DIR)/hardware/include/iob_portmap.vh
	cp $< $@

endif



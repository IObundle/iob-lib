ifeq ($(filter include, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=include

# Sources
SRC+=$(subst $(LIB_DIR)/hardware/include, $(BUILD_VSRC_DIR), $(wildcard $(LIB_DIR)/hardware/include/*.vh))

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/%.vh: $(LIB_DIR)/hardware/include/%.vh
	cp $< $(BUILD_VSRC_DIR)

ifneq ($(wildcard mkregs.toml),)
# iob slave port for swreg files
SRC+=$(BUILD_VSRC_DIR)/iob_s_port.vh
$(BUILD_VSRC_DIR)/iob_s_port.vh: iob_s_port.vh
	cp $< $@
iob_s_port.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_port '' ''

# iob slave portmap for swreg files
SRC+=$(BUILD_VSRC_DIR)/iob_s_portmap.vh
$(BUILD_VSRC_DIR)/iob_s_portmap.vh: iob_s_portmap.vh
	cp $< $@
iob_s_portmap.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_s_portmap '' ''
endif

endif

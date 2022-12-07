ifeq ($(filter iob2axis, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2axis

# Sources
SRC+=$(BUILD_SIM_DIR)/src/iob2axis.v
$(BUILD_SIM_DIR)/src/iob2axis.v: $(LIB_DIR)/hardware/iob2axis/iob2axis.v
	cp $< $@

# iob wires for host
SRC+=$(BUILD_SIM_DIR)/src/stream_iob_wire.vh
%/stream_iob_wire.vh:
	$(LIB_DIR)/scripts/if_gen.py iob_wire '$(@D)/stream_' 'stream_'

endif


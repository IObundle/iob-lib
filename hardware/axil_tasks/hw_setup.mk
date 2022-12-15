ifeq ($(filter axil_tasks, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil_tasks

# Sources
SRC+=$(BUILD_SIM_DIR)/src/axil_tasks.vh
$(BUILD_SIM_DIR)/src/axil_tasks.vh: $(LIB_DIR)/hardware/axil_tasks/axil_tasks.vh
	cp $< $@

endif

ifeq ($(filter iob_axil_tasks, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_axil_tasks

# Sources
SRC+=$(BUILD_SIM_DIR)/iob_axil_tasks.vh
$(BUILD_SIM_DIR)/iob_axil_tasks.vh: $(LIB_DIR)/hardware/iob_axil_tasks/iob_axil_tasks.vh
	cp $< $@

endif

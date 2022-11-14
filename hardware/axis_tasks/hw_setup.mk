ifeq ($(filter axis_tasks, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axis_tasks

# Sources
SRC+=$(BUILD_SIM_DIR)/axis_tasks.vh
$(BUILD_SIM_DIR)/axis_tasks.vh: $(LIB_DIR)/hardware/axis_tasks/axis_tasks.vh
	cp $< $@

endif

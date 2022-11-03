ifeq ($(filter iob_tasks, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_tasks

# Sources
SRC+=$(BUILD_SIM_DIR)/iob_tasks.vh
$(BUILD_SIM_DIR)/iob_tasks.vh: $(LIB_DIR)/hardware/iob_tasks/iob_tasks.vh
	cp $< $@

endif

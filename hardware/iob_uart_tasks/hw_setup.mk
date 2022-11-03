ifeq ($(filter iob_uart_tasks, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_uart_tasks

# Sources
SRC+=$(BUILD_SIM_DIR)/iob_uart_tasks.vh
$(BUILD_SIM_DIR)/iob_uart_tasks.vh: $(LIB_DIR)/hardware/iob_uart_tasks/iob_uart_tasks.vh
	cp $< $@

endif

ifeq ($(filter iob_counter, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_counter

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_counter/iob_counter.v

endif

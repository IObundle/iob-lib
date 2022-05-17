ifeq ($(filter iob_reverse, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_reverse

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_reverse/iob_reverse.v

endif

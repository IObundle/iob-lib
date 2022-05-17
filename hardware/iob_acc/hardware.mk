ifeq ($(filter iob_acc, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_acc

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_acc/iob_acc.v

endif

ifneq (iob2wishbone,$(filter iob2wishbone, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob2wishbone

# Sources
VSRC+=$(LIB_DIR)/hardware/iob2wishbone/iob2wishbone.v

endif

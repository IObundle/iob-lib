ifneq (iob2axil,$(filter iob2axil, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob2axil

# Sources
VSRC+=$(LIB_DIR)/hardware/iob2axil/iob2axil.v

endif

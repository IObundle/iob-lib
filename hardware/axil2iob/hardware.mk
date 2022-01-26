ifneq (axil2iob,$(filter axil2iob, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=axil2iob

# Sources
VSRC+=$(LIB_DIR)/hardware/axil2iob/axil2iob.v

endif

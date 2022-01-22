ifneq (axil2iob,$(filter axil2iob, $(MODULES)))

# Add to modules list
MODULES+=axil2iob

# Sources
VSRC+=$(LIB_DIR)/hardware/axil2iob/axil2iob.v

endif

ifneq (iob2axi,$(filter iob2axi, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob2axi

# Sources
VSRC+=$(LIB_DIR)/hardware/iob2axi/iob2axi.v

endif

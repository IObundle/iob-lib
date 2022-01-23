ifneq (iob2axi,$(filter iob2axi, $(MODULES)))

# Add to modules list
MODULES+=iob2axi

# Sources
VSRC+=$(LIB_DIR)/hardware/iob2axi/iob2axi.v

endif

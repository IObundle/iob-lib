ifneq (iob2axil,$(filter iob2axil, $(MODULES)))

# Add to modules list
MODULES+=iob2axil

# Sources
VSRC+=$(LIB_DIR)/hardware/iob2axil/iob2axil.v

endif

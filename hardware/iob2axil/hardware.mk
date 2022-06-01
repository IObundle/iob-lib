ifneq (iob2axil,$(filter iob2axil, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob2axil

# Includes
INCLUDE+=$(incdir)$(AXI_DIR)/hardware/include

# Sources
VSRC+=$(AXI_DIR)/hardware/iob2axil/iob2axil.v

endif

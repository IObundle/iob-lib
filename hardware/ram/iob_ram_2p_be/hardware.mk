ifneq ($(ASIC),1)
ifeq ($(filter iob_ram_2p_be, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p_be

# Sources
VSRC+=$(MEM_DIR)/hardware/ram/iob_ram_2p_be/iob_ram_2p_be.v

endif
endif

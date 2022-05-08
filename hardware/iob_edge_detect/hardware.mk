ifneq (iob_edge_detect,$(filter iob_edge_detect, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=iob_edge_detect

# Sources
VSRC+=$(LIB_DIR)/hardware/iob_edge_detect/iob_edge_detect.v

endif

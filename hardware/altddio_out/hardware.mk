ifneq (altddio_out,$(filter altddio_out, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=altddio_out

# Sources
VSRC+=$(LIB_DIR)/hardware/altddio_out/altddio_out.v

endif

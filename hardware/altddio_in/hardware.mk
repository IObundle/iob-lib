ifneq (altddio_in,$(filter altddio_in, $(HW_MODULES)))

# Add to modules list
HW_MODULES+=altddio_in

# Sources
VSRC+=$(LIB_DIR)/hardware/altddio_in/altddio_in.v

endif

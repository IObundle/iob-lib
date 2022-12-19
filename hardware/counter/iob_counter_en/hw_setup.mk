ifeq ($(filter iob_counter_en, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_counter_en

# Sources
SRC+=$(BUILD_VSRC_DIR)/iob_counter_en.v

# Copy the sources to the build directory 
$(BUILD_VSRC_DIR)/iob_counter_en.v: $(LIB_DIR)/hardware/counter/iob_counter_en/iob_counter_en.v
	cp $< $@

endif

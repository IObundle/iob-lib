
ifneq (iob2axil,$(filter iob2axil, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob2axil

# Sources 
VSRC+=$(BUILD_SRC_DIR)/iob2axil.v

# Copy the sources to the build directoy
$(BUILD_SRC_DIR)/iob2axil.v:$(LIB_DIR)/hardware/iob2axil/iob2axil.v
	cp $< $(BUILD_SRC_DIR)

endif

ifeq ($(filter iob_ram_2p_asym, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=iob_ram_2p_asym

# Needed modules
include $(LIB_DIR)/hardware/ram/iob_ram_2p/hw_setup.mk

# Sources
SRC+= \
$(BUILD_VSRC_DIR)/iob_ram_2p_asym_wgtr.v \
$(BUILD_VSRC_DIR)/iob_ram_2p_asym_wler.v

# Copy the sources to the buil;d directory
$(BUILD_VSRC_DIR)/iob_ram_2p_asym_wgtr.v: $(LIB_DIR)/hardware/ram/iob_ram_2p_asym/iob_ram_2p_asym_wgtr.v
	cp $< $@

$(BUILD_VSRC_DIR)/iob_ram_2p_asym_wler.v: $(LIB_DIR)/hardware/ram/iob_ram_2p_asym/iob_ram_2p_asym_wler.v
	cp $< $@

endif

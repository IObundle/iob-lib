ifeq ($(filter axil2iob, $(HW_MODULES)),)

# Add to modules list
HW_MODULES+=axil2iob

# import lib hardware
include $(LIB_DIR)/hardware/iob_reg/hw_setup.mk

# Sources
SRC+=$(BUILD_VSRC_DIR)/axil2iob.v
$(BUILD_VSRC_DIR)/axil2iob.v: $(LIB_DIR)/hardware/axil2iob/axil2iob.v
	cp $< $(BUILD_VSRC_DIR)

SRC+=$(BUILD_VSRC_DIR)/iob_axil_tasks.v
$(BUILD_VSRC_DIR)/iob_axil_tasks.v: $(LIB_DIR)/hardware/axil2iob/iob_axil_tasks.v
	cp $< $(BUILD_VSRC_DIR)

endif

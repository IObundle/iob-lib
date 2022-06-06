include iob_lib.mk

include $(CORE_DIR)/hardware/hardware.mk

build-dir: create-build-dir populate-build-dir

create-build-dir:
	mkdir -p $(BUILD_DIR)/vsrc
	mkdir -p $(BUILD_DIR)/sim
	mkdir -p $(BUILD_DIR)/fpga
	mkdir -p $(BUILD_DIR)/syn
	mkdir -p $(BUILD_DIR)/doc

populate-build-dir: $(VHDR) $(VSRC)


clean:
	rm -rf $(BUILD_DIR)

debug:
	@echo $(LIB_DIR)
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(BUILD_DIR)
	@echo $(CACHE_DIR)


.PHONY: build-dir create-build-dir populate-build-dir clean debug

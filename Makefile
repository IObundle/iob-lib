SHELL=/bin/bash
include iob_lib.mk

include $(CORE_DIR)/hardware/hardware.mk
include $(CORE_DIR)/hardware/simulation/sim-hw.mk
#include $(CORE_DIR)/hardware/fpga/fpga-hw.mk

build-dir: create-build-dir populate-build-dir

create-build-dir:
	mkdir -p $(BUILD_DIR)/vsrc
	mkdir -p $(BUILD_DIR)/sim
	mkdir -p $(BUILD_DIR)/fpga
	mkdir -p $(BUILD_DIR)/syn
	mkdir -p $(BUILD_DIR)/doc

populate-build-dir: $(VHDR) $(VSRC)
	cp hardware/simulation/*.mk $(BUILD_DIR)/sim
	mv $(BUILD_DIR)/sim/simulation.mk $(BUILD_DIR)/sim/Makefile
	cp $(CORE_DIR)/hardware/simulation/*.expected $(BUILD_DIR)/sim
	cp $(CORE_DIR)/hardware/simulation/*.mk $(BUILD_DIR)/sim
	cp $(CORE_DIR)/hardware/simulation/*.vh $(BUILD_DIR)/sim
	cp $(CORE_DIR)/hardware/simulation/*.v $(BUILD_DIR)/sim
	cp hardware/fpga/*.mk $(BUILD_DIR)/fpga                                    
	cp hardware/fpga/*.tcl $(BUILD_DIR)/fpga                                  
	mv $(BUILD_DIR)/fpga/fpga.mk $(BUILD_DIR)/fpga/Makefile                    
	cp $(CORE_DIR)/hardware/fpga/*.expected $(BUILD_DIR)/fpga
	cp $(CORE_DIR)/hardware/fpga/*.mk $(BUILD_DIR)/fpga
	cp $(CORE_DIR)/hardware/fpga/*.sdc $(BUILD_DIR)/fpga                       
	cp $(CORE_DIR)/hardware/fpga/*.xdc $(BUILD_DIR)/fpga        

debug:
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(BUILD_DIR)
	@echo $(CACHE_DIR)
	@echo $(VHDR)
	@echo $(VSRC1)
	@echo $(VSRC2)
	@echo $(VSRC)


.PHONY: build-dir create-build-dir populate-build-dir clean debug

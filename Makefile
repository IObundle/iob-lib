SHELL=/bin/bash
LIB_DIR=.
CORE_DIR=../..

BUILD_DIR = $(CORE_DIR)/$(TOP_MODULE)_$(VERSION_STR)


# import lib verilog header
VHDR+=$(BUILD_DIR)/vsrc/iob_lib.vh
$(BUILD_DIR)/vsrc/iob_lib.vh: hardware/include/iob_lib.vh
	cp $< $(BUILD_DIR)/vsrc

# import specific files
BUILD_SRC_DIR=$(BUILD_DIR)/vsrc
include $(CORE_DIR)/hardware/hardware.mk
include $(CORE_DIR)/hardware/simulation/simulation.mk

build-dir: $(BUILD_DIR) populate-build-dir

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)/vsrc
	mkdir -p $(BUILD_DIR)/sim
	mkdir -p $(BUILD_DIR)/fpga
	mkdir -p $(BUILD_DIR)/syn
	mkdir -p $(BUILD_DIR)/doc


CORE_SIM_DIR=$(CORE_DIR)/hardware/simulation
CORE_FPGA_DIR=$(CORE_DIR)/hardware/fpga
BUILD_SIM_DIR=$(BUILD_DIR)/sim
BUILD_FPGA_DIR=$(BUILD_DIR)/fpga

CONSTRAINTS=$(subst $(CORE_FPGA_DIR), $(BUILD_FPGA_DIR), $(wildcard $(CORE_FPGA_DIR)/*.sdc))
$(BUILD_FPGA_DIR)/%.sdc: $(CORE_FPGA_DIR)/%.sdc
	cp $< $@

populate-build-dir: $(BUILD_DIR) $(VHDR) $(VSRC) $(CONSTRAINTS)
	cp $(CORE_DIR)/info.mk $(BUILD_DIR)
	cp hardware/simulation/*.mk $(BUILD_SIM_DIR)
	mv $(BUILD_SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)/Makefile
	cp $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
	if [ "`ls $(CORE_SIM_DIR)/*.mk 2>/dev/null`" ];  then cp $(CORE_SIM_DIR)/*.mk $(BUILD_SIM_DIR); fi
	cp hardware/fpga/*.mk $(BUILD_DIR)/fpga                                    
	mv $(BUILD_DIR)/fpga/fpga.mk $(BUILD_DIR)/fpga/Makefile                    
	cp hardware/fpga/*.tcl $(BUILD_DIR)/fpga                                  
	cp $(CORE_FPGA_DIR)/*.expected $(BUILD_DIR)/fpga
	if [ "`ls $(CORE_FPGA_DIR)/*.mk 2>/dev/null`" ]; then cp $(CORE_FPGA_DIR)/*.mk $(BUILD_DIR)/fpga; fi
	cp $(CORE_FPGA_DIR)/*.sdc $(BUILD_DIR)/fpga


clean-build-dir:
	@rm -rf  $(BUILD_DIR)


gen-clean:
	@rm -f *# *~

clean-testlog:
	@rm -f test.log

clean-all: clean-testlog clean

debug:
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(BUILD_DIR)
	@echo $(BUILD_SRC_DIR)
	@echo $(CACHE_DIR)
	@echo $(VHDR)
	@echo $(VSRC1)
	@echo $(VSRC2)
	@echo $(VSRC)

.PHONY: build-dir populate-build-dir gen-clean clean-testlog clean-all debug

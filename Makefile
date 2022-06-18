# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile creates a build directory
#
# It should be called from the user core repository directory which is
# assumed to be located at ../.. and have iob-lib as submodule called LIB.
#
# The user core repository is assumed to have the structure typical of
# IObundle's repositories


SHELL=/bin/bash
LIB_DIR=.

# core paths
CORE_DIR=../..
CORE_HW_DIR=$(CORE_DIR)/hardware
CORE_SRC_DIR=$(CORE_HW_DIR)/src
CORE_INC_DIR=$(CORE_HW_DIR)/include
CORE_SIM_DIR=$(CORE_HW_DIR)/simulation
CORE_FPGA_DIR=$(CORE_HW_DIR)/fpga


# build dir paths
BUILD_DIR = $(CORE_DIR)/$(TOP_MODULE)_$(VERSION_STR)
BUILD_SRC_DIR=$(BUILD_DIR)/vsrc
BUILD_SIM_DIR=$(BUILD_DIR)/sim
BUILD_FPGA_DIR=$(BUILD_DIR)/fpga
BUILD_DOC_DIR=$(BUILD_DIR)/doc
BUILD_SYN_DIR=$(BUILD_DIR)/syn



# import lib verilog header
VHDR+=$(BUILD_SRC_DIR)/iob_lib.vh
$(BUILD_SRC_DIR)/iob_lib.vh: hardware/include/iob_lib.vh
	cp $< $(BUILD_SRC_DIR)

# import core files
include $(CORE_DIR)/hardware/hardware.mk

# make core version header file
VHDR+=$(BUILD_SRC_DIR)/$(TOP_MODULE)_version.vh
$(BUILD_SRC_DIR)/$(TOP_MODULE)_version.vh: $(TOP_MODULE)_version.vh
	cp $< $@

$(TOP_MODULE)_version.vh:
	./software/python/version.py $(TOP_MODULE) $(VERSION)

# import core simulation files
# verilog testbench
VSRC+=$(BUILD_SRC_DIR)/$(TOP_MODULE)_tb.v
$(BUILD_SRC_DIR)/$(TOP_MODULE)_tb.v: $(CORE_SIM_DIR)/$(TOP_MODULE)_tb.v
	cp $< $(BUILD_SRC_DIR)
# verilator testbench
VSRC+=$(BUILD_SRC_DIR)/$(TOP_MODULE)_tb.cpp
$(BUILD_SRC_DIR)/$(TOP_MODULE)_tb.cpp: $(CORE_SIM_DIR)/$(TOP_MODULE)_tb.cpp
	cp $< $(BUILD_SRC_DIR)
# import constraints files
CONSTRAINTS=$(subst $(CORE_FPGA_DIR), $(BUILD_SRC_DIR), $(wildcard $(CORE_FPGA_DIR)/*.sdc))
CONSTRAINTS+=$(subst $(CORE_FPGA_DIR), $(BUILD_SRC_DIR), $(wildcard $(CORE_FPGA_DIR)/*.xdc))
$(BUILD_SRC_DIR)/%.sdc: $(CORE_FPGA_DIR)/%.sdc
	cp $< $@
$(BUILD_SRC_DIR)/%.xdc: $(CORE_FPGA_DIR)/%.xdc
	cp $< $@


include $(CORE_DIR)/hardware/simulation/build.mk

build-dir: $(BUILD_DIR) populate

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)/vsrc
	mkdir -p $(BUILD_DIR)/sim
	mkdir -p $(BUILD_DIR)/fpga
	mkdir -p $(BUILD_DIR)/syn
	mkdir -p $(BUILD_DIR)/doc


populate: $(BUILD_DIR) $(BUILD_SRC_DIR)/top $(VHDR) $(VSRC) $(CONSTRAINTS)
	cp $(CORE_DIR)/info.mk $(BUILD_DIR)
	if [ -f $(CORE_HW_DIR)/hw-comp.mk ]; then cp $(CORE_HW_DIR)/hw-comp.mk $(BUILD_DIR); fi
	cp hardware/simulation/*.mk $(BUILD_SIM_DIR)
	mv $(BUILD_SIM_DIR)/simulation.mk $(BUILD_SIM_DIR)/Makefile
	cp $(CORE_SIM_DIR)/*.expected $(BUILD_SIM_DIR)
	if [ "`ls $(CORE_SIM_DIR)/*.mk 2>/dev/null`" ];  then cp $(CORE_SIM_DIR)/*.mk $(BUILD_SIM_DIR); fi
	cp hardware/fpga/*.mk $(BUILD_DIR)/fpga                                    
	mv $(BUILD_DIR)/fpga/fpga.mk $(BUILD_DIR)/fpga/Makefile                    
	cp hardware/fpga/*.tcl $(BUILD_DIR)/fpga                                  
	cp $(CORE_FPGA_DIR)/*.expected $(BUILD_DIR)/fpga
	if [ "`ls $(CORE_FPGA_DIR)/*.mk 2>/dev/null`" ]; then cp $(CORE_FPGA_DIR)/*.mk $(BUILD_DIR)/fpga; fi


clean:
	if [ -f $(BUILD_SIM_DIR)/Makefile ]; then make -C $(BUILD_SIM_DIR) clean; fi
	if [ -f $(BUILD_FPGA_DIR)/Makefile ]; then make -C $(BUILD_FPGA_DIR) clean; fi
	if [ -f $(BUILD_SYN_DIR)/Makefile ]; then make -C $(BUILD_SYN_DIR) clean; fi
	if [ -f $(BUILD_DOC_DIR)/Makefile ]; then make -C $(BUILD_DOC_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
	@rm -f *# *~ $(CORE_DIR)/*.vh *.vh

debug:
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(BUILD_DIR)
	@echo $(BUILD_SRC_DIR)
	@echo $(VHDR)
	@echo $(VSRC1)
	@echo $(VSRC2)
	@echo $(VSRC)
	@echo $(CONSTRAINTS)

.PHONY: build-dir populate-build-dir gen-clean clean-testlog clean-all debug

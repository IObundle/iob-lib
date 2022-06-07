#PATHS

CORE_DIR=../..
LIB_DIR=.

REMOTE_CORE_DIR ?= sandbox/$(TOP_MODULE)
HW_DIR:=$(CORE_DIR)/hardware
SW_DIR:=$(CORE_DIR)/software

#build directories
SIM_DIR ?=$(HW_DIR)/simulation
FPGA_DIR ?=$(HW_DIR)/fpga
DOC_DIR ?=$(CORE_DIR)/document

#DEFAULT SIMULATOR
SIMULATOR ?=icarus
SIMULATOR_LIST ?=icarus verilator

#DEFAULT FPGA FAMILY
FPGA_FAMILY ?=CYCLONEV-GT
FPGA_FAMILY_LIST ?=CYCLONEV-GT XCKU

#DEFAULT DOC
DOC ?=pb
DOC_LIST ?=pb ug


# VERSION

$(TOP_MODULE)_version.txt:
	echo $(VERSION) > version.txt


# BUILD DIRECTORY
BUILD_DIR := ../../$(TOP_MODULE)_$(VERSION)
BUILD_VSRC_DIR = $(BUILD_DIR)/vsrc



#lib verilog header
VHDR+=$(BUILD_VSRC_DIR)/iob_lib.vh
$(BUILD_VSRC_DIR)/iob_lib.vh: $(LIB_DIR)/hardware/include/iob_lib.vh
	cp $< $(BUILD_VSRC_DIR)

#core configuration
include $(CORE_DIR)/config.mk

$(TOP_MODULE)_conf.txt:
	$(foreach i, $(MACRO_LIST), echo "\`define $i $($i)" >> $@;)

VHDR+=$(BUILD_VSRC_DIR)/$(TOP_MODULE)_conf.vh
$(BUILD_VSRC_DIR)/$(TOP_MODULE)_conf.vh: $(TOP_MODULE)_conf.txt
	if [ ! -f $@ ]; then mv $< $@; elif [ "`diff -q $@ $<`" ];  then mv $< $@; fi

gen-clean:
	@rm -f *# *~

clean-testlog:
	@rm -f test.log

clean-all: clean-testlog clean

.PHONY: gen-clean clean-testlog clean-all

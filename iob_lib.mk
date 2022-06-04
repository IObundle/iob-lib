#PATHS

REMOTE_ROOT_DIR ?= sandbox/$(TOP_MODULE)
HW_DIR:=$(ROOT_DIR)/hardware
SW_DIR:=$(ROOT_DIR)/software

#build directories
SIM_DIR ?=$(HW_DIR)/simulation
FPGA_DIR ?=$(HW_DIR)/fpga
DOC_DIR ?=$(ROOT_DIR)/document

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
VERSION ?=0.1
VLINE ?="V$(VERSION)"
$(TOP_MODULE)_version.txt:
ifeq ($(VERSION),)
	$(error "variable VERSION is not set")
endif
	echo $(VLINE) > version.txt


#lib verilog header
VHDR+=iob_lib.vh
iob_lib.vh: $(LIB_DIR)/hardware/include/iob_lib.vh
	cp $< $@


gen-clean:
	@rm -f *# *~

clean-testlog:
	@rm -f test.log

clean-all: clean-testlog clean

.PHONY: gen-clean clean-testlog clean-all

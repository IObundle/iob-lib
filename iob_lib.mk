#PATHS
#paths that need disambiguation by prefix 
HW_DIR:=$(ROOT_DIR)/hardware
SW_DIR:=$(ROOT_DIR)/software

#paths that need no disambiguation
REMOTE_ROOT_DIR ?= sandbox/$(TOP_MODULE)
SIM_DIR ?=$(HW_DIR)/simulation/$(SIMULATOR)
#FPGA_DIR ?=$(shell find $(ROOT_DIR)/hardware -name $(FPGA_FAMILY))
FPGA_DIR ?=$(HW_DIR)/fpga
DOC_DIR ?=$(ROOT_DIR)/document/$(DOC)

# submodule paths
LIB_DIR ?=$(ROOT_DIR)/submodules/LIB
MEM_DIR ?=$(ROOT_DIR)/submodules/MEM
AXI_DIR ?=$(ROOT_DIR)/submodules/AXI


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

gen-clean:
	@rm -f *# *~

clean-testlog:
	@rm -f test.log

clean-all: clean-testlog clean

hw-clean: gen-clean
	@rm -f *.vh 

.PHONY: gen-clean clean-testlog clean-all hw-clean

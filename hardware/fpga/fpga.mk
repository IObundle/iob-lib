# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=/bin/bash
include ../info.mk
REMOTE_CORE_DIR=sandbox/$(TOP_MODULE)

VHDR=$(wildcard ../vsrc/*.vh)
VSRC=$(wildcard ../vsrc/*.v)

#select build makefile segment according to FPGA family
ifeq ($(FPGA_FAMILY),XCKU)
FPGA_PART:=xcku040-fbva676-1-c
include vivado.mk
else
#default FPGA_FAMILY: CYCLONEV-GT
FPGA_PART:=5CGTFD9E5F35C7
include quartus.mk
endif

build: 
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_CORE_DIR) ]; then mkdir -p $(REMOTE_CORE_DIR); fi"
	rsync -avz --exclude .git ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_CORE_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_CORE_DIR) fpga-build FPGA_FAMILY=$(FPGA_FAMILY)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_CORE_DIR)/$(BUILD_DIR)/fpga/$(FPGA_OBJ) .
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_CORE_DIR)/$(BUILD_DIR)/fpga/$(FPGA_LOG) .
endif

test: clean-all
	make build TEST_LOG=">> test.log"

clean-all: clean-testlog clean

debug:
	echo $(FPGA_SERVER)

.PHONY: build test clean-testlog clean clean-all debug

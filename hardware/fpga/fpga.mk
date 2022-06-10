SHELL:=/usr/bin/bash

#include $(CORE_DIR)/submodules/LIB/iob_lib.mk

VHDR=$(wildcard ../vsrc/*.vh)
VSRC=$(wildcard ../vsrc/*.v)

#select build makefile segment according to FPGA family
ifeq ($(FPGA_FAMILY),XCKU)
FPGA_PART:=xcku040-fbva676-1-c
include vivado.mk
else ifeq ($(FPGA_FAMILY),CYCLONEV-GT)
FPGA_PART:=5CGTFD9E5F35C7
include quartus.mk
endif

build: 
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_ROOT_DIR) ]; then mkdir -p $(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --exclude .git $(CORE_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-build FPGA_FAMILY=$(FPGA_FAMILY)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(FPGA_OBJ) .
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)/hardware/fpga/$(FPGA_LOG) .
endif

test: clean-all
	make build TEST_LOG=">> test.log"

clean:
ifeq ($(FPGA_SERVER),)
	find . -type f -not  \( $(NOCLEAN) \) -delete
else
	rsync -avz --delete --exclude .git $(CORE_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(REMOTE_ROOT_DIR); make fpga-clean FPGA_FAMILY=$(FPGA_FAMILY)'
endif

clean-all: clean-testlog clean

.PHONY: build test clean-testlog clean clean-all

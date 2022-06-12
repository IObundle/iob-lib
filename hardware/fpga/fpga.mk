SHELL:=/bin/bash

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
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_CORE_DIR) ]; then mkdir -p $(REMOTE_CORE_DIR); fi"
	rsync -avz --delete --exclude .git ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_CORE_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_CORE_DIR) fpga-build FPGA_FAMILY=$(FPGA_FAMILY)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_CORE_DIR)/$(BUILD_DIR_NAME)/fpga/$(FPGA_OBJ) .
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_CORE_DIR)/$(BUILD_DIR_NAME/fpga/$(FPGA_LOG) .
endif

test: clean-all
	make build TEST_LOG=">> test.log"

clean:
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'if [ -d $(REMOTE_CORE_DIR) ]; then make -C $(REMOTE_CORE_DIR) clean; fi'
endif

clean-all: clean-testlog clean

.PHONY: build test clean-testlog clean clean-all

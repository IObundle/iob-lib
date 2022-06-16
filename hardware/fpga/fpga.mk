# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=/bin/bash
include ../info.mk

REMOTE_BUILD_DIR=sandbox/$(TOP_MODULE)

#select build makefile segment according to FPGA family
ifeq ($(FPGA_FAMILY),XCKU)
FPGA_PART:=xcku040-fbva676-1-c
include vivado.mk
else
#default FPGA_FAMILY: CYCLONEV-GT
FPGA_PART:=5CGTFD9E5F35C7
include quartus.mk
endif

#include the module's headers and sources
VHDR=$(wildcard *.vh) $(wildcard ../vsrc/*.vh)
VSRC=$(wildcard *.v) $(wildcard ../vsrc/*.v)

build: $(VHDR) $(VSRC)
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --exclude .git .. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_BUILD_DIR)/fpga build FPGA_FAMILY=$(FPGA_FAMILY)'
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/fpga/$(FPGA_OBJ) .
	scp $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/fpga/$(FPGA_LOG) .
endif

clean:
	@rm -rf *
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'if [ -f $(REMOTE_BUILD_DIR)/fpga/Makefile ]; then make -C $(REMOTE_BUILD_DIR)/fpga clean; fi'
endif
debug:
	echo $(VHDR)
	echo $(VSRC)
	echo $(FPGA_SERVER)

.PHONY: build test clean debug

#include local fpga segment
ifneq ($(shell if [ -f fpga.mk ]; then echo yes; fi),)
include fpga.mk
endif

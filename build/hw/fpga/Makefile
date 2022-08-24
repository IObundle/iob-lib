# This file becomes the fpga makefile when copied to the build
# directory

SHELL:=/bin/bash

#include local fpga segment
ifneq ($(wildcard fpga.mk),)
include fpga.mk
endif

REMOTE_BUILD_DIR=sandbox/$(NAME)_$(VERSION_STR)

#include the module's headers and sources
VHDR=$(wildcard ../vsrc/*.vh)
VSRC+=$(wildcard ../vsrc/*.v)

#select FPGA part and family
#default FPGA_FAMILY
FPGA_FAMILY?=CYCLONEV-GT
ifeq ($(FPGA_FAMILY),XCKU)
FPGA_PART:=xcku040-fbva676-1-c
include vivado.mk
else
#default part
FPGA_PART:=5CGTFD9E5F35C7
include quartus.mk
endif

build: $(VHDR) $(VSRC)
ifeq ($(FPGA_SERVER),)
	make $(FPGA_OBJ)
else 
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync $(FPGA_SYNC_FLAGS) -avz --force ../.. $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hw/fpga $@ TOP_MODULE=$(TOP_MODULE) FPGA_FAMILY=$(FPGA_FAMILY)'
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/hw/fpga/$(FPGA_OBJ) .
	scp $(FPGA_SCP_FLAGS) $(FPGA_USER)@$(FPGA_SERVER):$(REMOTE_BUILD_DIR)/hw/fpga/$(FPGA_LOG) .
endif

clean:
	@find . -maxdepth 1 -type d -not \( -name '.' \) -exec rm -rf {} \;
	@find . -type f -not \( -name "Makefile" -o -name "*.mk" -o -name "*.expected" -o -name "*.tcl" -o -name "*.sdc" -o -name "*.xdc" \) -delete
ifneq ($(FPGA_SERVER),)
	ssh $(FPGA_SSH_FLAGS) $(FPGA_USER)@$(FPGA_SERVER) 'if [ -f $(REMOTE_BUILD_DIR)/hw/fpga/Makefile ]; then make -C $(REMOTE_BUILD_DIR)/hw/fpga clean; fi'
endif

test: clean clean-test-log $(TEST_LIST)
	diff test.log test.expected

clean-test-log:
	rm -f test.log

debug:
	@echo $(VHDR)
	@echo $(VSRC)
	@echo $(FPGA_SERVER)
	@echo $(FPGA_OBJ)

.PHONY: build test clean debug

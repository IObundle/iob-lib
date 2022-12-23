# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash

include ../../config_build.mk

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)
REMOTE_LINT_DIR=$(REMOTE_BUILD_DIR)/hardware/lint

#include the module's headers and sources
VHDR+=$(wildcard ../src/*.vh)
VSRC+=$(wildcard ../src/*.v)

$(NAME)_files.list: $(VHDR) $(VSRC)

.PHONY: run $(VSRC) clean

$(VHDR) $(VSRC):
	@ls $@ >> $(NAME)_files.list

#select linter
#default linter
LINTER?=spyglass
include $(LINTER).mk

run: clean $(NAME)_files.list
	make run-lint LINTER=$(LINTER)

clean:
	make clean-lint LINTER=$(LINTER)

debug:
	@echo NAME=$(NAME)
	@echo VHDR=$(VHDR)
	@echo VSRC=$(VSRC)
	@echo VFLAGS=$(VFLAGS)
	@echo $(TEST_LIST)

.PRECIOUS: uut.vcd

.PHONY: run clean

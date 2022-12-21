# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash 

include ../../../config.mk
#include the module's headers and sources
VHDR+=$(wildcard ../../src/*.vh)
VSRC+=$(wildcard ../../src/*.v)

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)

LINT_SERVER=$(ALINT_SERVER)
LINT_USER=$(ALINT_USER)
LINT_SSH_FLAGS=$(ALINT_SSH_FLAGS)
LINT_SCP_FLAGS=$(ALINT_SCP_FLAGS)
LINT_SYNC_FLAGS=$(ALINT_SYNC_FLAGS)

$(NAME)_files.list: $(VHDR) $(VSRC)

.PHONY: run $(VSRC) clean

$(VHDR) $(VSRC):
	@ls $@ >> $(NAME)_files.list

run: clean $(NAME)_files.list
ifeq ($(LINT_SERVER),)
ifneq ($(ALINT_INIT_SCRIPT),)
	set -e; source $(ALINT_INIT_SCRIPT); echo exit | alintcon -batch -do alintpro.tcl
else
	echo exit | alintcon -batch -do alintpro.tcl
endif
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) ../../.. $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/lint/alint run'
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)/hardware/lint/alint/violations.* .
endif

clean:
	rm -rf $(NAME)_files.list
	rm -f violation.*

debug:
	@echo $(VHDR)

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

SHELL:=bash 

include ../../../config_build.mk
#include the module's headers and sources
VHDR+=$(wildcard ../../src/*.vh)
VSRC+=$(wildcard ../../src/*.v)

REMOTE_BUILD_DIR=$(USER)/$(BUILD_DIR_NAME)

LINT_SERVER=$(SYNOPSYS_SERVER)
LINT_USER=$(SYNOPSYS_USER)
LINT_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
LINT_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
LINT_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)

$(NAME)_files.list: $(VHDR) $(VSRC)

.PHONY: run $(VSRC) clean

$(VHDR) $(VSRC):
	@ls $@ >> $(NAME)_files.list

run: clean $(NAME)_files.list
ifeq ($(LINT_SERVER),)
	echo exit | spyglass -shell -project iob_lint.prj -goals "lint/lint_rtl"
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) ../../.. $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_BUILD_DIR)/hardware/lint/spyglass run'
	mkdir -p reports
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)/hardware/lint/spyglass/iob_lint/consolidated_reports/$(NAME)_lint_lint_rtl/*.rpt reports/.
endif

clean:
	rm -rf $(NAME)_files.list
	rm -rf reports

debug:
	@echo $(VHDR)

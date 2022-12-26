# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

LINT_SERVER=$(SYNOPSYS_SERVER)
LINT_USER=$(SYNOPSYS_USER)
LINT_SSH_FLAGS=$(SYNOPSYS_SSH_FLAGS)
LINT_SCP_FLAGS=$(SYNOPSYS_SCP_FLAGS)
LINT_SYNC_FLAGS=$(SYNOPSYS_SYNC_FLAGS)

run-lint:
ifeq ($(LINT_SERVER),)
	echo exit | spyglass -shell -project spyglass/iob_lint.prj -goals "lint/lint_rtl"
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) ../.. $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_LINT_DIR) run LINTER=$(LINTER)'
	mkdir -p spyglass/reports
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_LINT_DIR)/iob_lint/consolidated_reports/$(NAME)_lint_lint_rtl/*.rpt spyglass/reports/.
endif

clean-lint:
	rm -rf $(NAME)_files.list
	rm -rf spyglass/reports

debug:
	@echo $(VHDR)

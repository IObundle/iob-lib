# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

LINT_SERVER=$(ALINT_SERVER)
LINT_USER=$(ALINT_USER)
LINT_SSH_FLAGS=$(ALINT_SSH_FLAGS)
LINT_SCP_FLAGS=$(ALINT_SCP_FLAGS)
LINT_SYNC_FLAGS=$(ALINT_SYNC_FLAGS)

run-lint:
ifeq ($(LINT_SERVER),)
ifneq ($(ALINT_INIT_SCRIPT),)
	set -e; source $(ALINT_INIT_SCRIPT); echo exit | alintcon -batch -do alint/alintpro.tcl
else
	echo exit | alintcon -batch -do alintpro.tcl
endif
else
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) "if [ ! -d $(REMOTE_BUILD_DIR) ]; then mkdir -p $(REMOTE_BUILD_DIR); fi"
	rsync -avz --delete --exclude .git $(LINT_SYNC_FLAGS) ../.. $(LINT_USER)@$(LINT_SERVER):$(REMOTE_BUILD_DIR)
	ssh $(LINT_SSH_FLAGS) $(LINT_USER)@$(LINT_SERVER) 'make -C $(REMOTE_LINT_DIR) run LINTER=$(LINTER)'
	scp $(LINT_SCP_FLAGS) $(LINT_USER)@$(LINT_SERVER):$(REMOTE_LINT_DIR)/alint/violations.* alint/.
endif

clean-lint:
	rm -rf $(NAME)_files.list
	rm -f alint/violation.*

debug:
	@echo $(VHDR)

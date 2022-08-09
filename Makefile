# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile creates a build directory for an IP core
#
# It should be called from the user core repository directory which is
# assumed to be located at ../.. and have iob-lib as submodule called LIB.
#
# The user core repository is assumed to have the structure typical of
# IObundle's repositories

SHELL=/bin/bash
export

# core path
CORE_DIR ?=.

ifeq ($(CORE_DIR),.)
include test.mk
else
include setup.mk
endif 

clean:
	@$(eval SUB_CORE_DIRS:=$(shell find $(CORE_DIR)/submodules/ -name info.mk -printf '%h\n'))
	@for subcore_dir in $(SUB_CORE_DIRS); do make -C $${subcore_dir} clean; done
	@if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
	@rm -f $(CORE_DIR)/*.vh *.vh
	@rm -f *~ \#*\# a.out *.vcd *.pyc *.log *.v

debug: $(BUILD_DIR) $(VHDR) 
	@echo $(TOP_MODULE)
	@echo $(VERSION)
	@echo $(VERSION_STR)
	@echo $(BUILD_DIR)
	@echo $(BUILD_VSRC_DIR)
	@echo $(VHDR)
	@echo $(VSRC1)
	@echo $(VSRC2)
	@echo $(VSRC)
	@echo $(MODULE) $(MODULE_DIR)
	@echo $(IS_ASYM)

.PHONY: clean debug

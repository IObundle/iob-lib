# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used to create a build directory for an IP core or to
# simulate the modules in this repository
#
# To create a build directory from any directory:
# > make -C /path/to/iob-lib setup
#
# To simulate a module in this:
# > make -C /path/to/iob-lib sim MODULE=<some module in the hardware directory>
#


SHELL=/bin/bash
export

ifeq ($(MAKECMDGOALS),sim)
CORE_DIR =.
include test.mk
else
CORE_DIR =../..
include setup.mk
endif 

clean:
	@if [ -f $(BUILD_DIR)/Makefile ]; then make -C $(BUILD_DIR) clean; fi
	@rm -rf $(BUILD_DIR)
	@rm -f *.v *.vh *.c *.h *.tex
	@rm -f *~ \#*\# a.out *.vcd *.pyc *.log

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
	@echo $(MAKECMDGOALS)

.PHONY: clean debug

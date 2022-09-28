SFLAGS =-errormax 15 -status
VFLAGS+=$(SFLAGS) -update -linedebug -sv
EFLAGS =$(SFLAGS) -access +wc

ifneq ($(SIM_INIT_SCRIPT),)
INIT_SCRIPT=set -e; source $(SIM_INIT_SCRIPT);
endif

ifeq ($(VCD),1)
VFLAGS+=-define VCD
endif

comp: $(VHDR) $(VSRC)
	$(INIT_SCRIPT) xmvlog $(VFLAGS) $(VSRC); xmelab $(EFLAGS) worklib.$(NAME)_tb:module

exec:
	$(INIT_SCRIPT) xmsim $(SFLAGS) worklib.$(NAME)_tb:module
	grep -v xcelium xmsim.log | grep -v xmsim | grep -v "\$finish" | tee -a test.log

.PHONY: comp exec

SFLAGS =-errormax 15 -status
VFLAGS+=$(SFLAGS) -update -linedebug -sv
EFLAGS =$(SFLAGS) -access +wc

ifeq ($(VCD),1)
VFLAGS+=-define VCD
endif

comp: $(VHDR) $(VSRC)
	xmvlog $(VFLAGS) $(VSRC); xmelab $(EFLAGS) worklib.$(NAME)_tb:module

exec:
	xmsim $(SFLAGS) worklib.$(NAME)_tb:module
	grep -v xcelium xmsim.log | grep -v xmsim | grep -v "\$finish" | tee -a test.log

.PHONY: comp exec

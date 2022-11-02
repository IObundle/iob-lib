SFLAGS =-errormax 15 -status
VFLAGS+=$(SFLAGS) -update -linedebug -sv -incdir . -incdir ../src
EFLAGS =$(SFLAGS) -access +wc

ifeq ($(VCD),1)
VFLAGS+=-define VCD
endif

SIM_SERVER=$(CADENCE_SERVER)
SIM_USER=$(CADENCE_USER)
SIM_SSH_FLAGS=$(CADENCE_SSH_FLAGS)
SIM_SCP_FLAGS=$(CADENCE_SCP_FLAGS)
SIM_SYNC_FLAGS=$(CADENCE_SYNC_FLAGS)

comp: $(VHDR) $(VSRC)
	xmvlog $(VFLAGS) $(VSRC); xmelab $(EFLAGS) worklib.$(NAME)_tb:module

exec:
	xmsim $(SFLAGS) worklib.$(NAME)_tb:module
	grep -v xcelium xmsim.log | grep -v xmsim | grep -v "\$finish" | tee -a test.log

.PHONY: comp exec

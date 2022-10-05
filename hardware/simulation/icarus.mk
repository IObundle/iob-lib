VFLAGS+=-W all -g2005-sv -I. -I../src

ifeq ($(VCD),1)
VFLAGS+=-DVCD
endif

SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)

comp: a.out

a.out: $(VHDR) $(VSRC)
	iverilog $(VFLAGS) $(VSRC)

exec:
	./a.out | tee -a test.log

.PHONY: comp exec

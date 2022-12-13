VFLAGS+=-W all -g2005-sv -I. -I../src -Isrc $(DEFINES)

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

clean: gen-clean
	@rm -f a.out

very-clean: clean

.PHONY: comp exec clean very-clean

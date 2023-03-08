VFLAGS+=-W all -g2005-sv -I. -I../src -Isrc $(DEFINES)

ifeq ($(VCD),1)
VFLAGS+=-DVCD
endif

ifneq ($(VTOP),)
VFLAGS+=-s $(VTOP)
endif

SIM_SERVER=$(IVSIM_SERVER)
SIM_USER=$(IVSIM_USER)

SIM_PROC=a.out

comp: $(SIM_PROC)

$(SIM_PROC): $(VHDR) $(VSRC)
	iverilog $(VFLAGS) $(VSRC)

exec:
	./$(SIM_PROC) | tee -a test.log

clean: gen-clean
	@rm -f $(SIM_PROC)

very-clean: clean

.PHONY: comp exec clean very-clean

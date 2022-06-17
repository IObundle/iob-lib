VFLAGS=-W all -g2005-sv -I. -I../vsrc $(VSRC)

ifeq ($(VCD),1)
VFLAGS+=-DVCD
endif

comp: a.out

a.out:
	iverilog $(VFLAGS)

exec:
	./a.out $(TEST_LOG)
ifeq ($(VCD),1)
	if [ "`pgrep -u $(USER) gtkwave`" ]; then killall -q -9 gtkwave; fi
	gtkwave -a ../waves.gtkw uut.vcd &
endif	

.PHONY: comp exec

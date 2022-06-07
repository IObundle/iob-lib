comp: $(VHDR) $(VSRC)
	iverilog -W all -g2005-sv -I../vsrc $(VSRC)

exec:
	./a.out $(TEST_LOG)
ifeq ($(VCD),1)
	if [ "`pgrep -u $(USER) gtkwave`" ]; then killall -q -9 gtkwave; fi
	gtkwave -a ../waves.gtkw uut.vcd &
endif	

clean: sim-clean
	@rm -f a.out

.PHONY: comp exec clean

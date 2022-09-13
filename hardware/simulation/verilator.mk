VFLAGS+=--cc --exe -I. -I../src --top-module $(VTOP)
VFLAGS+=-Wno-lint

ifeq ($(VCD),1)
VFLAGS+=--trace
endif

comp: $(VHDR) $(VSRC)
	verilator $(VFLAGS) $(VSRC) $(NAME)_tb.cpp	
	cd ./obj_dir && make -f V$(VTOP).mk

exec:
	./obj_dir/V$(VTOP) | tee -a test.log

.PHONY: comp exec

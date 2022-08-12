defmacro:=-D

VSRC_VLTR=$(filter-out ../vsrc/$(NAME)_tb.v, $(VSRC))

VFLAGS+=--cc --exe -I. -I../vsrc $(VSRC_VLTR) ../vsrc/$(NAME)_tb.cpp --top-module $(VTOP)
VFLAGS+=-Wno-lint

ifeq ($(VCD),1)
VFLAGS+=--trace
endif

comp: $(VHDR) $(VSRC)
	verilator $(VFLAGS) $(WAVE)	
	cd ./obj_dir && make -f V$(VTOP).mk

exec:
	./obj_dir/V$(VTOP) | tee -a test.log

.PHONY: comp exec

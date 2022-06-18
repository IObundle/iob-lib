VSRC_VLTR=$(filter-out ../vsrc/$(TOP_MODULE)_tb.v, $(VSRC))

VFLAGS+=--cc --exe -I. -I../vsrc $(VSRC_VLTR) ../vsrc/$(TOP_MODULE)_tb.cpp --top-module $(VTOP)
VFLAGS+=-Wno-lint

ifeq ($(VCD),1)
VFLAGS+=--trace
endif

TEST_LOG=test.log

comp: $(VHDR) $(VSRC)
	echo $(TOP_MODULE)
	verilator $(VFLAGS) $(WAVE)	
	cd ./obj_dir && make -f V$(VTOP).mk

exec:
	./obj_dir/V$(VTOP) | tee -a $(TEST_LOG)

.PHONY: comp exec

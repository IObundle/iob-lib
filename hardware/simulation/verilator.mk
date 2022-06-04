#module paths
VFLAGS=--cc --exe -I. $(VSRC) $(TOP_MODULE)_tb.cpp --top-module $(VTOP)
VFLAGS+=-Wno-lint

ifeq ($(VCD),1)
VFLAGS+=--trace
endif

comp:
	verilator $(VFLAGS) $(WAVE)	
	cd ./obj_dir && make -f V$(VTOP).mk

exec: $(VSRC) $(VHDR)
	./obj_dir/V$(VTOP) $(TEST_LOG)

clean: sim-clean
	@rm -rf ./obj_dir

.PHONY: run clean

VTOP?=$(NAME)

VFLAGS+=--cc --exe -I. -I../src --top-module $(VTOP)
VFLAGS+=-Wno-lint

ifeq ($(VCD),1)
VFLAGS+=--trace
endif

SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)

comp: $(VHDR) $(VSRC)
	verilator $(VFLAGS) $(VSRC) $(NAME)_tb.cpp	
	cd ./obj_dir && make -f V$(VTOP).mk

exec:
	./obj_dir/V$(VTOP) | tee -a test.log

clean: gen-clean
	@rm -rf obj_dir

.PHONY: comp exec clean

VFLAGS+=--cc --exe -I. -I../src --top-module $(NAME)
VFLAGS+=-Wno-lint

ifeq ($(VCD),1)
VFLAGS+=--trace
endif

SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)

comp: $(VHDR) $(VSRC)
	verilator $(VFLAGS) $(VSRC) $(NAME)_tb.cpp	
	cd ./obj_dir && make -f V$(NAME).mk

exec:
	./obj_dir/V$(NAME) | tee -a test.log

.PHONY: comp exec

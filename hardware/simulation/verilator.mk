VTOP?=$(NAME)

VFLAGS+=--cc --exe -I. -I../src -Isrc --top-module $(VTOP)
VFLAGS+=-Wno-lint
# Include embedded headers
VFLAGS+=-CFLAGS "-I../../../software/esrc"

VFLAGS+=$(DEFINES)

ifeq ($(VCD),1)
VFLAGS+=--trace
VFLAGS+=-DVCD -CFLAGS "-DVCD"
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

very-clean: clean

.PHONY: comp exec clean

VTOP?=$(NAME)

VFLAGS+=--cc --exe -I. -I../src -Isrc --top-module $(VTOP)
VFLAGS+=-Wno-lint
VFLAGS+=--timing
# Include embedded headers
VFLAGS+=-CFLAGS "-I../../../software/esrc"

VFLAGS+=$(DEFINES)

# Set build-time defines from the build_defines.txt file
VFLAGS+=$(addprefix -D,$(file < ../../build_defines.txt))
VFLAGS+=-CFLAGS "$(addprefix -D,$(file < ../../build_defines.txt))"

ifeq ($(VCD),1)
VFLAGS+=--trace
VFLAGS+=-DVCD -CFLAGS "-DVCD"
endif

SIM_SERVER=$(VSIM_SERVER)
SIM_USER=$(VSIM_USER)

SIM_PROC=V$(VTOP)

comp: $(VHDR) $(VSRC)
	verilator $(VFLAGS) $(VSRC) src/$(NAME)_tb.cpp	
	cd ./obj_dir && make -f $(SIM_PROC).mk

exec:
	./obj_dir/$(SIM_PROC) | tee -a test.log

clean: gen-clean
	@rm -rf obj_dir

very-clean: clean

.PHONY: comp exec clean

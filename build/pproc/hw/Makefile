# Preprocess hardware Makefile
# Setup needed files to use CORE as submodule
# 1. Preprocessed verilog sources
# 2. Instance verilog segment
# 3. Headers used by SOC Core
#
include ../../info.mk

PPROC_VSRC:=$(TOP_MODULE)_pproc.v
INSTANCE:=$(wildcard inst.vh)
PPROC_VHDR:=$(wildcard $(NAME)_swreg_def.vh)

VHDR=$(filter-out $(INSTANCE) $(PPROC_VHDR),$(wildcard *.vh))
VSRC=$(filter-out $(PPROC_VSRC),$(wildcard *.v))

VFLAGS:=-E					# preprocess sources
VFLAGS+=-o $(PPROC_VSRC)	# output verilog file
VFLAGS+=-W all -g2005-sv	# warnings and verilog version

all: build

build: $(VHDR) $(VSRC)
	iverilog $(VFLAGS) $(VSRC)
	@rm -rf $(VSRC) $(VHDR)

clean:
	@rm -rf $(PPROC_VSRC) $(PPROC_VHDR) $(INSTANCE) $(VSRC) $(VHDR) 

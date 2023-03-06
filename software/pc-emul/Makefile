# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time in $(BUILD_DIR)/sw/pc/Makefile
#

include ../../config_build.mk

ifneq ($(wildcard ../../console.mk),)
include ../../console.mk
endif

# compiler flags
CFLAGS=-Os -std=gnu99 -Wl,--strip-debug

CONSOLE_CMD=../../scripts/console.py -L

INCLUDE=-I.
INCLUDE+=-I../src

HDR=$(wildcard *.h)
HDR+=$(wildcard ../psrc/*.h)

SRC=$(wildcard *.c)
SRC+=$(wildcard ../psrc/*.c)

# include local pc-emul segment
# all previously defined variables can be overwritten in this file
ifneq ($(wildcard pcemul_build.mk),)
include pcemul_build.mk
endif

fw_emul: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(INCLUDE) $(SRC) -lgcc -lc

build: bsp.h fw_emul
	@echo "build"

run: build
	@rm -f soc2cnsl cnsl2soc
	$(CONSOLE_CMD) $(TEST_LOG) &
	bash -c "trap 'make kill-cnsl' INT TERM KILL EXIT; ./fw_emul $(TEST_LOG)"


# Create bsp.h based on bsp.vh of simulation
bsp.h:
	cp ../../hardware/simulation/bsp.vh $@
	sed -i 's/`/#/' $@

test: clean $(TEST_LIST)
	diff test.log test.expected

# TODO add to iob-soc custom clean list
# CLEAN_LIST+=kill-cnsl

clean: $(CLEAN_LIST)
	@rm -rf fw_emul test.log soc2cnsl cnsl2soc
	@rm -rf *.txt

.PHONY: build run clean test

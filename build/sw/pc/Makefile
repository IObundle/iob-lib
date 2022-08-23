CORE_DIR:=../..
include $(CORE_DIR)/info.mk
ifneq ($(wildcard $(CORE_DIR)/config.mk),)
include $(CORE_DIR)/config.mk
endif

# compiler flags
CFLAGS=-Os -std=gnu99 -Wl,--strip-debug

CONSOLE_CMD=../python/console -L

DEFINE+=PC

INCLUDE=-I.
INCLUDE+=-I../src

HDR=$(wildcard *.h)
HDR+=$(wildcard ../src/*.h)

SRC=$(wildcard *.c)
SRC+=$(wildcard ../src/*.c)

# include local pc-emul segment
# all previously defined variables can be overwritten in this file
ifneq ($(wildcard pc-emul.mk),)
include pc-emul.mk
endif

fw_emul: $(HDR) $(SRC)
	gcc -o $@ $(CFLAGS) $(INCLUDE) $(SRC) -lgcc -lc

build: fw_emul
	@echo "build"

run: build
	@rm -f soc2cnsl cnsl2soc
	$(CONSOLE_CMD) $(TEST_LOG) &
	bash -c "trap 'make kill-cnsl' INT TERM KILL EXIT; ./fw_emul $(TEST_LOG)"

test: clean $(TEST_LIST)
	diff test.log test.expected

ifneq ($(SETUP_SW),0)
CLEAN_LIST+=kill-cnsl
endif

clean: $(CLEAN_LIST)
	@rm -rf fw_emul test.log soc2cnsl cnsl2soc
	@rm -rf *.txt

.PHONY: build run clean test

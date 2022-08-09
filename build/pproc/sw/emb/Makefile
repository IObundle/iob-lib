# Preprocess hardware Makefile
# Setup needed files to use CORE as submodule
# 1. Compile Objects
# 2. Create static library
# 3. Headers used by SOC Core
#
include ../../../info.mk

TOOLCHAIN_PREFIX:=riscv64-unknown-elf-

STATIC_LIB:=$(NAME)_emb.so

OBJ:=$(patsubst %.c,%.o,$(wildcard *.c))
HDR:=$(wildcard *.h)

MFLAGS=$(MFLAGS_BASE)$(MFLAG_M)$(MFLAG_C)

MFLAGS_BASE:=rv32i

ifeq ($(USE_MUL_DIV),1)
MFLAG_M=m
endif

ifeq ($(USE_COMPRESSED),1)
MFLAG_C=c
endif

CFLAGS=-Os 
CFLAGS+=-nostdlib 
CFLAGS+=-march=$(MFLAGS) -mabi=ilp32 
CFLAGS+=--specs=nano.specs 
CFLAGS+=-Wcast-align=strict

all: build

build: $(STATIC_LIB)

$(STATIC_LIB): $(OBJ)
	$(TOOLCHAIN_PREFIX)ar cr $@ $^

%.o: %.c $(HDR)
	$(TOOLCHAIN_PREFIX)gcc $(CFLAGS) -c $< -o $@

clean:
	@rm -rf $(STATIC_LIB) $(OBJ)

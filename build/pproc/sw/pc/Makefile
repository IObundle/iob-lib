# Preprocess hardware Makefile
# Setup needed files to use CORE as submodule
# 1. Compile Objects
# 2. Create static library
# 3. Headers used by SOC Core
#
include ../../../info.mk

STATIC_LIB:=$(NAME)_pc.so

OBJ:=$(patsubst %.c,%.o,$(wildcard *.c))
HDR:=$(wildcard *.h)

CFLAGS=-Os 
CFLAGS+=-std=gnu99 
CFLAGS+=-Wl,--strip-debug

DEFINE+=-DPC

all: build

build: $(STATIC_LIB)

$(STATIC_LIB): $(OBJ)
	ar cr $@ $^

%.o: %.c $(HDR)
	gcc $(CFLAGS) -c $< -o $@ $(DEFINE)

clean:
	@rm -rf $(STATIC_LIB) $(OBJ)

# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time in $(BUILD_DIR)/software/embedded/Makefile
#

include ../../info.mk

TEMPLATE_LDS=../esrc/template.lds

MFLAGS=$(MFLAGS_BASE)$(MFLAG_M)$(MFLAG_C)
MFLAGS_BASE:=rv32i
ifeq ($(USE_MUL_DIV),1)
MFLAG_M=m
endif
ifeq ($(USE_COMPRESSED),1)
MFLAG_C=c
endif

#compiler settings
TOOLCHAIN_PREFIX:=riscv64-unknown-elf-
CFLAGS=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32 --specs=nano.specs -Wcast-align=strict
LFLAGS= -Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug
LLIBS=-lgcc -lc -lnosys

HDR=$(wildcard *.h)
HDR+=$(wildcard ../esrc/*.h)


#FW_SRC=$(wildcard *.c)
FW_SRC=$(wildcard ../firmware/*)
FW_SRC+=$(wildcard ../esrc/*.c)

# include local build segment
# all previously defined variables can be overwritten in this file
ifneq ($(wildcard emb_build.mk),)
include embed_build.mk
endif

build: firmware.elf 

firmware.elf: $(TEMPLATE_LDS) $(HDR) $(FW_SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(FW_LFLAGS) -I. -I../firmware -I../esrc $(FW_SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary $@ firmware.bin

clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex

debug:
	@echo $(TEMPLATE_LDS)
	@echo $(FW_SRC)
	@echo $(HDR)

.PHONY: build clean debug


# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time in $(BUILD_DIR)/software/embedded/Makefile
#

include ../../config_build.mk

TEMPLATE_LDS ?=../template.lds

MFLAGS=$(MFLAGS_BASE)$(MFLAG_M)$(MFLAG_C)
MFLAGS_BASE:=rv32i
ifeq ($(USE_MUL_DIV),1)
MFLAG_M=m
endif
ifeq ($(USE_COMPRESSED),1)
MFLAG_C=c
endif

#default compiler settings
TOOLCHAIN_PREFIX ?=riscv64-unknown-elf-
CFLAGS ?=-Os -nostdlib -march=$(MFLAGS) -mabi=ilp32 --specs=nano.specs -Wcast-align=strict
LFLAGS ?= -Wl,-Bstatic,-T,$(TEMPLATE_LDS),--strip-debug
LLIBS ?=-lgcc -lc -lnosys
INCLUDES ?=-I. -I../esrc

# Set build-time defines from the build_defines.txt file
CFLAGS+=$(addprefix -D,$(file < ../../build_defines.txt))

# include local build segment
# all previously defined variables can be overwritten in this file
ifneq ($(wildcard embed_build.mk),)
include embed_build.mk
endif

build: bsp.h $(UTARGETS)
%.elf: $(TEMPLATE_LDS) $(HDR) $(SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(LFLAGS) $(DEFINES) $(INCLUDES) $(SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary $@ $(*F).bin

ifneq ($(BOARD),)
FPGA_TOOL:=$(shell find ../../hardware/fpga -name $(BOARD) | cut -d"/" -f2)
endif

# Create bsp.h based on bsp.vh
bsp.h:
ifneq ($(BOARD),)
	cp ../../hardware/fpga/$(FPGA_TOOL)/$(BOARD)/bsp.vh $@
else
	cp ../../hardware/simulation/bsp.vh $@
endif
	sed -i 's/`/#/' $@

clean:
	@rm -rf *.bin *.elf *.map *.hex

debug:
	@echo $(TEMPLATE_LDS)
	@echo $(FW_SRC)
	@echo $(BOOT_SRC)
	@echo $(HDR)

.PHONY: build clean debug


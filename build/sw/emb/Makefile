CORE_DIR:=../..
include $(CORE_DIR)/info.mk
ifneq ($(wildcard $(CORE_DIR)/config.mk),)
include $(CORE_DIR)/config.mk
endif

TEMPLATE_LDS=../src/template.lds

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

BOOT_LFLAGS=$(LFLAGS) -Wl,-Map,boot.map
FW_LFLAGS=$(LFLAGS) -Wl,-Map,firmware.map

INCLUDE=-I.
INCLUDE+=-I../src

HDR=$(wildcard *.h)
HDR+=$(wildcard ../src/*.h)

BOOT_SRC=$(wildcard *.c)
BOOT_SRC+=../src/boot.c ../src/boot.S

FW_SRC=$(wildcard *.c)
FW_SRC+=$(wildcard ../src/*.c)
FW_SRC+=../src/firmware.S
# exclude bootloader sources
FW_SRC:=$(filter-out %boot.c,$(FW_SRC))

# include local embedded segment
# all previously defined variables can be overwritten in this file
ifneq ($(wildcard embedded.mk),)
include embedded.mk
endif

build-all: fw-build boot-build

fw-build: firmware.elf

firmware.elf: $(TEMPLATE_LDS) $(HDR) $(FW_SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(FW_LFLAGS) $(INCLUDE) $(FW_SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary $@ firmware.bin

boot-build: boot.elf

boot.elf: $(TEMPLATE_LDS) $(HDR) $(BOOT_SRC)
	$(TOOLCHAIN_PREFIX)gcc -o $@ $(CFLAGS) $(BOOT_LFLAGS) $(INCLUDE) $(BOOT_SRC) $(LLIBS)
	$(TOOLCHAIN_PREFIX)objcopy -O binary $@ boot.bin

clean-all: fw-clean boot-clean $(CLEAN_LIST)

fw-clean:
	@rm -rf firmware.bin firmware.elf firmware.map *.hex

boot-clean:
	@rm -rf boot.bin boot.elf boot.map *.hex

.PHONY: build-all fw-build boot-build\
	clean-all fw-clean boot-clean


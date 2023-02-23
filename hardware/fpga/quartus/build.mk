ifeq ($(IS_FPGA),1)
FPGA_OBJ:=$(FPGA_TOP).sof
else
FPGA_OBJ:=$(FPGA_TOP).qxp
endif

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)
FPGA_ENV=$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh
FPGA_PROG=$(FPGA_ENV) quartus_pgm -m jtag -c 1 -o 'p;$(FPGA_TOP).sof'

QUARTUS_FLAGS = -t quartus/build.tcl $(FPGA_TOP) $(BOARD) "$(VSRC)" "$(IP)" $(IS_FPGA) $(USE_EXTMEM) $(QUARTUS_SEED)

$(FPGA_OBJ): $(VHDR) $(VSRC) $(IP) $(wildcard *.sdc)
	$(FPGA_ENV) quartus_sh $(QUARTUS_FLAGS)
	@if [ -f reports/$(FPGA_OBJ) ]; then mv reports/$(FPGA_OBJ) $(FPGA_OBJ); fi

quartus-clean:
	@rm -rf incremental_db db reports
	@find ~ -maxdepth 1 -type d -empty -iname "sopc_altera_pll*" -delete

.PHONY: quartus-clean

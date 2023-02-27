# (c) 2022-Present IObundle, Lda, all rights reserved
#
# This makefile is used at build-time
#

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)
FPGA_SSH_FLAGS=$(QUARTUS_SSH_FLAGS)
FPGA_SCP_FLAGS=$(QUARTUS_SCP_FLAGS)
FPGA_SYNC_FLAGS=$(QUARTUS_SYNC_FLAGS)


ifeq ($(IS_FPGA),1)
FPGA_OBJ:=$(FPGA_TOP).sof
else
FPGA_OBJ:=resynthesis/$(FPGA_TOP).vqm
endif


FPGA_ENV=$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh
FPGA_PROG=$(FPGA_ENV) quartus_pgm -m jtag -c 1 -o 'p;$(FPGA_TOP).sof'

# Set build-time defines from the build_defines.txt file
DEFINES+=$(file < ../../build_defines.txt)
QUARTUS_FLAGS = -t quartus/build.tcl $(FPGA_TOP) $(BOARD) "$(VSRC)" "$(DEFINES)" "$(IP)" $(IS_FPGA) $(USE_EXTMEM) $(QUARTUS_SEED)

$(FPGA_OBJ): $(VHDR) $(VSRC) $(IP) $(wildcard $(BOARD)/*.sdc)
	$(FPGA_ENV) quartus_sh $(QUARTUS_FLAGS)

quartus-clean:
	@rm -rf incremental_db db reports
	@find ~ -maxdepth 1 -type d -empty -iname "sopc_altera_pll*" -delete

.PHONY: quartus-clean

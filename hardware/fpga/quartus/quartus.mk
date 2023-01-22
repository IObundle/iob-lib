ifeq ($(IS_FPGA),1)
FPGA_OBJ:=$(NAME).sof
else
FPGA_OBJ:=$(NAME).qxp
endif

FPGA_LOG=quartus.log
NORUN=0

FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)
FPGA_ENV=$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh
FPGA_PROG=$(FPGA_ENV) quartus_pgm -m jtag -c 1 -o 'p;iob_soc.sof'

$(FPGA_OBJ): $(VHDR) $(VSRC) $(wildcard *.sdc)
	$(FPGA_ENV) quartus_sh -t quartus/quartus.tcl $(NAME) $(BOARD) "$(VSRC)" $(IS_FPGA)
	@mv output_files/*.fit.summary $(FPGA_LOG)
	@mv output_files/$(FPGA_OBJ) $(FPGA_OBJ)

quartus-clean:
	@rm -rf incremental_db db output_files

.PHONY: quartus-clean

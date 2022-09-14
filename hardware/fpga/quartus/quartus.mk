ifeq ($(IS_FPGA),1)
FPGA_OBJ:=$(NAME).sof
else
FPGA_OBJ:=$(NAME).qxp
endif

FPGA_LOG=quartus.log


FPGA_SERVER=$(QUARTUS_SERVER)
FPGA_USER=$(QUARTUS_USER)
FPGA_ENV=$(QUARTUSPATH)/nios2eds/nios2_command_shell.sh

$(FPGA_OBJ): $(VHDR) $(VSRC) $(wildcard *.sdc)
	$(FPGA_ENV) quartus_sh -t fpga_tool.tcl $(NAME) $(TOP_MODULE) "$(VSRC)" $(IS_FPGA)
	mv output_files/*.fit.summary $(FPGA_LOG)

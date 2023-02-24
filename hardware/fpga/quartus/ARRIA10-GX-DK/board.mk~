BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

ifeq ($(USE_EXTMEM),1)

QIP_FILE:=$(FPGA_TOOL)/$(BOARD)/alt_ddr3/synthesis/alt_ddr3.qip
IP+=$(QIP_FILE)

$(QIP_FILE):
	$(FPGA_ENV) qsys-generate --synthesis $(FPGA_TOOL)/$(BOARD)/alt_ddr3.qsys

else

IP+=$(FPGA_TOOL)/$(BOARD)/alt_ddr3.qsys

endif

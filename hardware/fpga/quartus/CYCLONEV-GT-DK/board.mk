BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

ifeq ($(USE_EXTMEM),1)
QIP=$(FPGA_TOOL)/$(BOARD)/alt_ddr3/synthesis/alt_ddr3.qip
$(QIP): $(FPGA_TOOL)/$(BOARD)/alt_ddr3.qsys
	$(FPGA_ENV) qsys-generate --synthesis $<
else
QIP="None"
endif

BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

QIP_FILE=$(FPGA_TOOL)/$(BOARD)/alt_ddr3.qip

ifeq ($(USE_DDR),1)
FPGA_DEPS+=$(QIP_FILE)
endif

$(QIP_FILE): $(FPGA_TOOL)/$(BOARD)/alt_ddr3.qsys
	$(FPGA_ENV) qsys-generate --synthesis $<

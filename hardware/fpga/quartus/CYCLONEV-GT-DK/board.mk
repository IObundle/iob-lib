BOARD_SERVER=$(CYC5_SERVER)
BOARD_USER=$(CYC5_USER)

IP+=" "
ifeq ($(USE_EXTMEM),1)
IP+=$(FPGA_TOOL)/$(BOARD)/alt_ddr3.qsys
else

endif

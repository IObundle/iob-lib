           //CPU native interface
           //START_IO_TABLE iob_s
           `IOB_INPUT(valid,   1),        //Native CPU interface valid signal
           `IOB_INPUT(address, ADDR_W),   //Native CPU interface address signal
           `IOB_INPUT(wdata,   DATA_W),   //Native CPU interface data write signal
           `IOB_INPUT(wstrb,   DATA_W/8), //Native CPU interface write strobe signal
           `IOB_OUTPUT(rdata,  DATA_W),   //Native CPU interface read data signal
           `IOB_OUTPUT(ready,  1),        //Native CPU interface ready signal

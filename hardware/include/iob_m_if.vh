      //CPU native interface
      //START_IO_TABLE iob_m
      `IOB_OUTPUT(valid, 1),        //Native CPU interface valid signal
      `IOB_OUTPUT(addr,  ADDR_W),   //Native CPU interface address signal
      `IOB_OUTPUT(wdata, DATA_W),   //Native CPU interface data write signal
      `IOB_OUTPUT(wstrb, DATA_W/8), //Native CPU interface write strobe signal
      `IOB_INPUT(rdata,  DATA_W),   //Native CPU interface read data signal
      `IOB_INPUT(ready,  1),        //Native CPU interface ready signal

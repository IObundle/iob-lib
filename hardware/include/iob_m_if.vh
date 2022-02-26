      //CPU native interface
      //START_IO_TABLE iob_m
      `OUTPUT(valid, 1),        //Native CPU interface valid signal
      `OUTPUT(addr,  ADDR_W),   //Native CPU interface address signal
      `OUTPUT(wdata, DATA_W),   //Native CPU interface data write signal
      `OUTPUT(wstrb, DATA_W/8), //Native CPU interface write strobe signal
      `INPUT(rdata,  DATA_W),   //Native CPU interface read data signal
      `INPUT(ready,  1),        //Native CPU interface ready signal

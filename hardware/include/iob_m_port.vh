//IOb native interface
//START_IO_TABLE iob_m
  `IOB_OUTPUT(valid, 1),        //Request valid.
  `IOB_INPUT(ready,  1),        //Interface ready.
  `IOB_OUTPUT(addr,  ADDR_W),   //Address.
  `IOB_OUTPUT(wdata, DATA_W),   //Write data.
  `IOB_OUTPUT(wstrb, DATA_W/8), //Write strobe.
  `IOB_INPUT(rvalid, 1),        //Read data valid.
  `IOB_INPUT(rdata,  DATA_W),   //Read data.

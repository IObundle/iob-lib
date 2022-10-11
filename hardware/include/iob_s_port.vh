//IOb native interface
//START_IO_TABLE iob_s
  `IOB_INPUT(valid,   1),        //Request valid.
  `IOB_OUTPUT(ready,  1),        //Interface ready.
  `IOB_INPUT(addr,    ADDR_W),   //Address.
  `IOB_INPUT(wdata,   DATA_W),   //Write data.
  `IOB_INPUT(wstrb,   DATA_W/8), //Write strobe.
  `IOB_OUTPUT(rvalid, 1),        //Read data valid.
  `IOB_OUTPUT(rdata,  DATA_W),   //Read data.

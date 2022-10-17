//IOb native interface
//START_IO_TABLE iob_m
  `IOB_OUTPUT(valid_o, 1),        //Request valid.
  `IOB_INPUT(ready_i,  1),        //Interface ready.
  `IOB_OUTPUT(addr_o,  ADDR_W),   //Address.
  `IOB_OUTPUT(wdata_o, DATA_W),   //Write data.
  `IOB_OUTPUT(wstrb_o, DATA_W/8), //Write strobe.
  `IOB_INPUT(rvalid_i, 1),        //Read data valid.
  `IOB_INPUT(rdata_i,  DATA_W),   //Read data.

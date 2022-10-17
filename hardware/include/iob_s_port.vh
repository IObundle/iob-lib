//IOb native interface
//START_IO_TABLE iob_s
  `IOB_INPUT(valid_i,   1),        //Request valid.
  `IOB_OUTPUT(ready_o,  1),        //Interface ready.
  `IOB_INPUT(addr_i,    ADDR_W),   //Address.
  `IOB_INPUT(wdata_i,   DATA_W),   //Write data.
  `IOB_INPUT(wstrb_i,   DATA_W/8), //Write strobe.
  `IOB_OUTPUT(rvalid_o, 1),        //Read data valid.
  `IOB_OUTPUT(rdata_o,  DATA_W),   //Read data.

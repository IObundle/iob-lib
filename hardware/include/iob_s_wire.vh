`IOB_WIRE(valid_i, 1)        //Request valid.
`IOB_WIRE(ready_o,  1)       //Interface ready.
`IOB_WIRE(addr_i,  ADDR_W)   //Address.
`IOB_WIRE(wdata_i, DATA_W)   //Write data.
`IOB_WIRE(wstrb_i, DATA_W/8) //Write strobe.
`IOB_WIRE(rvalid_o, 1)       //Read data valid.
`IOB_WIRE(rdata_o,  DATA_W)  //Read data.

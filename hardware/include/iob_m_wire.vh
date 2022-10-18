`IOB_WIRE(valid_o, 1)        //Request valid.
`IOB_WIRE(ready_i,  1)       //Interface ready.
`IOB_WIRE(addr_o,  ADDR_W)   //Address.
`IOB_WIRE(wdata_o, DATA_W)   //Write data.
`IOB_WIRE(wstrb_o, DATA_W/8) //Write strobe.
`IOB_WIRE(rvalid_i, 1)       //Read data valid.
`IOB_WIRE(rdata_i,  DATA_W)  //Read data.

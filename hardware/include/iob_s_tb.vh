`IOB_WIRE(valid, 1)        //Request valid.
`IOB_VAR(ready,  1)        //Interface ready.
`IOB_WIRE(addr,  ADDR_W)   //Address.
`IOB_WIRE(wdata, DATA_W)   //Write data.
`IOB_WIRE(wstrb, DATA_W/8) //Write strobe.
`IOB_VAR(rvalid, 1)        //Read data valid.
`IOB_VAR(rdata,  DATA_W)   //Read data.

`IOB_VAR(valid,   1)        //Request valid.
`IOB_WIRE(ready,  1)        //Interface ready.
`IOB_VAR(addr,    ADDR_W)   //Address.
`IOB_VAR(wdata,   DATA_W)   //Write data.
`IOB_VAR(wstrb,   DATA_W/8) //Write strobe.
`IOB_WIRE(rvalid, 1)        //Read data valid.
`IOB_WIRE(rdata,  DATA_W)   //Read data.

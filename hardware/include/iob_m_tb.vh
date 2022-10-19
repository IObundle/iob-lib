`IOB_VAR(valid_v, 1)        //Request valid.
`IOB_WIRE(ready,  1)        //Interface ready.
`IOB_VAR(addr_v,  ADDR_W)   //Address.
`IOB_VAR(wdata_v, DATA_W)   //Write data.
`IOB_VAR(wstrb_v, DATA_W/8) //Write strobe.
`IOB_WIRE(rvalid, 1)        //Read data valid.
`IOB_WIRE(rdata,  DATA_W)   //Read data.

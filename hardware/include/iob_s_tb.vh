`IOB_WIRE(valid_w, 1)        //Request valid.
`IOB_VAR(ready_v,  1)        //Interface ready.
`IOB_WIRE(addr_w,  ADDR_W)   //Address.
`IOB_WIRE(wdata_w, DATA_W)   //Write data.
`IOB_WIRE(wstrb_w, DATA_W/8) //Write strobe.
`IOB_VAR(rvalid_v, 1)        //Read data valid.
`IOB_VAR(rdata_V,  DATA_W)   //Read data.

`IOB_WIRE(valid,   1)        //Request valid.
`IOB_VAR(ready_v,  1)        //Interface ready.
`IOB_WIRE(addr,    ADDR_W)   //Address.
`IOB_WIRE(wdata,   DATA_W)   //Write data.
`IOB_WIRE(wstrb,   DATA_W/8) //Write strobe.
`IOB_VAR(rvalid_v, 1)        //Read data valid.
`IOB_VAR(rdata_v,  DATA_W)   //Read data.

initial begin
   ready_v = 0;
   rvalid_v = 0;
   rdata_v = 0;
end

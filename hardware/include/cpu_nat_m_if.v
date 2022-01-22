      `OUTPUT(clk,   1),
      `OUTPUT(rst,   1),
      `OUTPUT(valid, 1),
      `OUTPUT(addr,  ADDR_W-9),
      `OUTPUT(wdata, DATA_W),      
      `OUTPUT(wstrb, DATA_W/8),
      `INPUT(rdata,  DATA_W),
      `INPUT(ready,  1)

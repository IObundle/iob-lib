`include "axi.vh"

   //native interface signals 
   `WIRE(valid, 1)
   `WIRE(ready, 1)
   `WIRE(address, AXIL_ADDR_W)
   `WIRE(wdata, AXIL_DATA_W)
   `WIRE(wstrb, 4)
   `WIRE(rdata, AXIL_DATA_W)

   //AXI TO NATIVE INTERFACE ADAPTER
   axil2iob #
     (
      .AXIL_ADDR_W(AXIL_ADDR_W),
      .AXIL_DATA_W(AXIL_DATA_W)
      )
   axil2iob0
     (
      .clk (clk),
      .rst (rst),

      `AXI4_LITE_IF_PORTMAP(s_, s_),

      //native interface
      .valid(valid),
      .ready(ready),
      .addr(address),
      .wdata(wdata),
      .wstrb(wstrb),
      .rdata(rdata)
      );

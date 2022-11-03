//
// Tasks for the AXI4 protocol
//

// Write data to AXI4 Lite slave
task axil_write;
   input [AXIL_ADDR_W-1:0]  addr;
   input [AXIL_DATA_W-1:0]  data;
   input [$clog2(AXIL_DATA_W):0] width;
   localparam DATA_W = AXIL_DATA_W;

   begin
      // Write address
      @(posedge clk) axil_awaddr_i  = #1 `IOB_WORD_ADDR(addr);
      axil_awvalid_i = 1;
   
      // Write response
      axil_bready_i = 1;
      
      // Write data
      axil_wdata_i  = `IOB_GET_WDATA(addr, data);
      axil_wstrb_i  = `IOB_GET_WSTRB(addr, width);
      axil_wvalid_i = 1;
   
      while (!axil_awready_o) #1;
      while (!axil_wready_o) #1;
   
      @(posedge clk) axil_awvalid_i = #1 0;
      axil_wvalid_i = 0;
   end
endtask

// Read data from AXI4 Lite slave
task axil_read;
   input [AXIL_ADDR_W-1:0]       addr;
   input [$clog2(AXIL_DATA_W):0] width;
   localparam DATA_W = AXIL_DATA_W;

   begin
      axil_wstrb_i  = 0;

      // Read address
      @(posedge clk) axil_araddr_i  = #1 `IOB_WORD_ADDR(addr);
      axil_arvalid_i = 1;

      // Read data
      axil_rready_i = 1;

      while (!axil_arready_o) #1;
      @(posedge clk) axil_arvalid_i = #1 0;

      while (!axil_rvalid_o) #1;
      @(posedge clk) rxdata = #1 `IOB_GET_RDATA(addr, axil_rdata_o, width);
   end
endtask

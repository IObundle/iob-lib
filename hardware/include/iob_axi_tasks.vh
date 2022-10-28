//
// Tasks for the AXI4 protocol
//

// Write data to AXI4 Lite slave
task axil_write;
   input [AXIL_ADDR_W-1:0]       axil_addr_task;
   input [AXIL_DATA_W-1:0]       axil_data_task;
   input [$clog2(AXIL_DATA_W):0] axil_width_task;

   localparam ADDR_W = AXIL_ADDR_W;
   localparam DATA_W = AXIL_DATA_W;

   begin
      // Write address
      axil_awaddr  = `IOB_WORD_ADDR(axil_addr_task);
      axil_awvalid = 1;
      
      // Write response
      axil_bready = 1;

      // Write data
      axil_wdata  = `IOB_GET_WDATA(axil_addr_task, axil_data_task);
      axil_wstrb  = `IOB_GET_WSTRB(axil_addr_task, axil_width_task);
      axil_wvalid = 1;

      while (!axil_awready) #1;
      while (!axil_wready) @(posedge clk) #1;

      @(posedge clk) axil_awvalid = 0;
      axil_wvalid = 0;
   end
endtask

// Read data from AXI4 Lite slave
task axil_read;
   input [AXIL_ADDR_W-1:0]       axil_addr_task;
   output [AXIL_DATA_W-1:0]      axil_data_task;
   input [$clog2(AXIL_DATA_W):0] axil_width_task;

   localparam ADDR_W = AXIL_ADDR_W;
   localparam DATA_W = AXIL_DATA_W;

   begin
      axil_wstrb  = 0;

      // Read address
      axil_araddr  = `IOB_WORD_ADDR(axil_addr_task);
      axil_arvalid = 1;

      // Read data
      axil_rready = 1;

      @(posedge clk) #1;
      while (!axil_arready) @(posedge clk) #1;
       @(posedge clk) axil_arvalid = #1 0;

      while (!axil_rvalid) #1;
      axil_data_task = #1 `IOB_GET_RDATA(axil_addr_task, axil_rdata, axil_width_task);

   end
endtask

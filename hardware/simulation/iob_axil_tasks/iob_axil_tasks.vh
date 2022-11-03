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
      axil_awaddr_i  = `IOB_WORD_ADDR(axil_addr_task);
      axil_awvalid_i = 1;
      
      // Write response
      axil_bready_i = 1;

      // Write data
      axil_wdata_i  = `IOB_GET_WDATA(axil_addr_task, axil_data_task);
      axil_wstrb_i  = `IOB_GET_WSTRB(axil_addr_task, axil_width_task);
      axil_wvalid_i = 1;

      while (!axil_awready_o) #1;
      while (!axil_wready_o) @(posedge clk) #1;

      @(posedge clk) axil_awvalid_i = 0;
      axil_wvalid_i = 0;
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
      axil_wstrb_i  = 0;

      // Read address
      axil_araddr_i  = `IOB_WORD_ADDR(axil_addr_task);
      axil_arvalid_i = 1;

      // Read data
      axil_rready_i = 1;

      @(posedge clk) #1;
      while (!axil_arready_o) @(posedge clk) #1;
      @(posedge clk) axil_arvalid_i = #1 0;

      while (!axil_rvalid_o) #1;
      axil_data_task = #1 `IOB_GET_RDATA(axil_addr_task, axil_rdata_o, axil_width_task);

   end
endtask

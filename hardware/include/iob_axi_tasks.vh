//
// Tasks for the AXI4 protocol
//

// Write data to AXI-4 lite slave
task write_data_axil;
   input [AXIL_ADDR_W-1:0]       axil_addr_task;
   input [AXIL_DATA_W-1:0]       axil_data_task;
   input [$clog2(AXIL_DATA_W):0] axil_width_task;

   localparam ADDR_W = AXIL_ADDR_W;
   localparam DATA_W = AXIL_DATA_W;

   reg                           axil_wready_int;

   begin
      // Write address
      axil_awaddr  = `IOB_WORD_ADDR(axil_addr_task);
      axil_awvalid = 1'b1;

      // Write data
      axil_wdata  = `IOB_GET_WDATA(axil_addr_task, axil_data_task);
      axil_wstrb  = `IOB_GET_WSTRB(axil_addr_task, axil_width_task);
      axil_wvalid = 1'b1;

      while (!axil_awready) begin
         @(negedge clk);
      end

      axil_wready_int = axil_wready;

      @(posedge clk) #1;
      axil_awvalid = 1'b0;

      if (!axil_wready_int) begin
         while (!axil_wready) begin
            @(negedge clk);
         end

         @(posedge clk) #1;
      end

      axil_wvalid = 1'b0;
      axil_wstrb  = {(AXIL_DATA_W/8){1'b0}};

      // Write response
      if (!axil_bvalid) begin
         @(negedge clk);
      end

      @(posedge clk) #1;
      axil_bready = 1'b1;

      @(posedge clk) #1;
      axil_bready = 1'b0;

      @(posedge clk) #1;
   end
endtask

// Read data from AXI-4 lite slave
task read_data_axil;
   input [AXIL_ADDR_W-1:0]       axil_addr_task;
   output [AXIL_DATA_W-1:0]      axil_data_task;
   input [$clog2(AXIL_DATA_W):0] axil_width_task;

   localparam ADDR_W = AXIL_ADDR_W;
   localparam DATA_W = AXIL_DATA_W;

   reg                           axil_rvalid_int;

   begin
      // Read address
      axil_araddr  = `IOB_WORD_ADDR(axil_addr_task);
      axil_arvalid = 1'b1;

      while (!axil_arready) begin
         @(negedge clk);
      end

      axil_rvalid_int = axil_rvalid;

      @(posedge clk) #1;
      axil_arvalid = 1'b0;

      // Read data
      if (!axil_rvalid_int) begin
         while (!axil_rvalid) begin
            @(negedge clk);
         end

         @(posedge clk) #1;
      end

      axil_rready = 1'b1;

      axil_data_task = `IOB_GET_RDATA(axil_addr_task, axil_rdata, axil_width_task);

      @(posedge clk) #1;

      axil_rready = 1'b0;

      @(posedge clk) #1;
   end
endtask

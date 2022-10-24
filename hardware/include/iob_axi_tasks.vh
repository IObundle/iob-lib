//
// Tasks for the AXI4 protocol
//

// Write data to AXI-4 lite slave
task write_data_axil;
   input [AXIL_ADDR_W-1:0]       axilAddress;
   input [AXIL_DATA_W-1:0]       axilData;
   input [$clog2(AXIL_DATA_W):0] axilWidth;

   localparam ADDR_W = AXIL_ADDR_W;
   localparam DATA_W = AXIL_DATA_W;

   reg                           axil_wready_int;

   begin
      // Write address
      axil_awaddr  = `IOB_WORD_ADDR(axilAddress);
      axil_awvalid = 1'b1;

      // Write data
      axil_wdata  = axilData << (8 * `IOB_BYTE_OFFSET(axilAddress));
      axil_wstrb  = ((1 << `IOB_GET_NBYTES(axilWidth)) - 1) << `IOB_BYTE_OFFSET(axilAddress);
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
   input [AXIL_ADDR_W-1:0]       axilAddress;
   output [AXIL_DATA_W-1:0]      axilData;
   input [$clog2(AXIL_DATA_W):0] axilWidth;

   localparam ADDR_W = AXIL_ADDR_W;
   localparam DATA_W = AXIL_DATA_W;

   reg                           axil_rvalid_int;

   begin
      // Read address
      axil_araddr  = `IOB_WORD_ADDR(axilAddress);
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

      axilData = (axil_rdata >> (8 * `IOB_BYTE_OFFSET(axilAddress))) & ((1 << axilWidth) - 1);

      @(posedge clk) #1;

      axil_rready = 1'b0;

      @(posedge clk) #1;
   end
endtask

//
// Tasks for the AXI-4 protocol
//

function integer ceil2byte(integer num);
   if (num % 8)
     return ((num/8 + 1) * 8);
   else
     return num;
endfunction

// Write data to AXI-4 lite slave
task write_data_axil;
   input [AXIL_ADDR_W-1:0]         axilAddress;
   input [AXIL_DATA_W-1:0]         axilData;
   input [$clog2(AXIL_DATA_W):0]   axilWidth;

   reg                             axil_wready_int;
   reg [$clog2(AXIL_DATA_W/8)-1:0] axilOffset;
   reg [AXIL_DATA_W-1:0]           axilData_int;
   reg [AXIL_DATA_W/8-1:0]         axilStrb_int;

   begin
      axilOffset   = axilAddress[$clog2(AXIL_DATA_W/8)-1:0];
      axilData_int = axilData << (8 * axilOffset);
      axilStrb_int = ((1 << ceil2byte(axilWidth)/8) - 1) << axilOffset;

      // Write address
      axil_awaddr  = axilAddress;
      axil_awvalid = 1'b1;

      // Write data
      axil_wdata  = axilData_int;
      axil_wstrb  = axilStrb_int;
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
   input [AXIL_ADDR_W-1:0]         axilAddress;
   output [AXIL_DATA_W-1:0]        axilData;

   reg                             axil_rvalid_int;
   reg [$clog2(AXIL_DATA_W/8)-1:0] axilOffset;

   begin
      // Read address
      axil_araddr  = axilAddress;
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

      axilOffset = axilAddress[$clog2(AXIL_DATA_W/8)-1:0];
      axilData   = axil_rdata >> (8 * axilOffset);

      @(posedge clk) #1;

      axil_rready = 1'b0;

      @(posedge clk) #1;
   end
endtask

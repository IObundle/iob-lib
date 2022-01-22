`timescale 1ns/1ps

module iob2axi_tb;

   parameter clk_frequency = `CLK_FREQ;
   parameter clk_per = 1e9/clk_frequency; // clock period in ns

   parameter DATA_W = 32;
   parameter ADDR_W = 10;

   // System signals
   reg                 clk;
   reg                 rst;

   // Native interface
   reg                 valid;
   reg [ADDR_W-1:0]    addr;
   reg [DATA_W-1:0]    wdata;
   reg [DATA_W/8-1:0]  wstrb;
   wire [DATA_W-1:0]   rdata;
   wire                ready;

   // AXI4-lite interface
   // Master Interface Write Address
   wire [ADDR_W-1:0]   M_AXI_AWADDR;
   wire [2:0]          M_AXI_AWPROT;
   wire                M_AXI_AWVALID;
   wire                M_AXI_AWREADY;

   // Master Interface Write Data
   wire [DATA_W-1:0]   M_AXI_WDATA;
   wire [DATA_W/8-1:0] M_AXI_WSTRB;
   wire                M_AXI_WVALID;
   wire                M_AXI_WREADY;

   // Master Interface Write Response
   wire [1:0]          M_AXI_BRESP;
   wire                M_AXI_BVALID;
   wire                M_AXI_BREADY;

   // Master Interface Read Address
   wire [ADDR_W-1:0]   M_AXI_ARADDR;
   wire [2:0]          M_AXI_ARPROT;
   wire                M_AXI_ARVALID;
   wire                M_AXI_ARREADY;

   // Master Interface Read Data 
   wire [DATA_W-1:0]   M_AXI_RDATA;
   wire [1:0]          M_AXI_RRESP;
   wire                M_AXI_RVALID;
   wire                M_AXI_RREADY;

   // auxilary signals

   // iterator
   integer                      i;

   // Instantiate the Unit Under Test (UUT)
   iob2axi # (
              .ADDR_W(ADDR_W),
              .DATA_W(DATA_W)
              )
     uut (
		  .clk(clk),
		  .rst(rst),

          // Native interface
          .valid(valid),
          .addr(addr),
          .wdata(wdata),
          .wstrb(wstrb),
          .rdata(rdata),
          .ready(ready),

          // AXI4-lite interface
          // Master Interface Write Address
          .M_AXI_AWADDR(M_AXI_AWADDR),
          .M_AXI_AWPROT(M_AXI_AWPROT),
          .M_AXI_AWVALID(M_AXI_AWVALID),
          .M_AXI_AWREADY(M_AXI_AWREADY),

          // Master Interface Write Data
          .M_AXI_WDATA(M_AXI_WDATA),
          .M_AXI_WSTRB(M_AXI_WSTRB),
          .M_AXI_WVALID(M_AXI_WVALID),
          .M_AXI_WREADY(M_AXI_WREADY),

          // Master Interface Write Response
          .M_AXI_BRESP(M_AXI_BRESP),
          .M_AXI_BVALID(M_AXI_BVALID),
          .M_AXI_BREADY(M_AXI_BREADY),

          // Master Interface Read Address
          .M_AXI_ARADDR(M_AXI_ARADDR),
          .M_AXI_ARPROT(M_AXI_ARPROT),
          .M_AXI_ARVALID(M_AXI_ARVALID),
          .M_AXI_ARREADY(M_AXI_ARREADY),

          // Master Interface Read Data 
          .M_AXI_RDATA(M_AXI_RDATA),
          .M_AXI_RRESP(M_AXI_RRESP),
          .M_AXI_RVALID(M_AXI_RVALID),
          .M_AXI_RREADY(M_AXI_RREADY)
		  );

   axil_ram # (
               //.PIPELINE_OUTPUT(3),
               .DATA_WIDTH(DATA_W),
               .ADDR_WIDTH(ADDR_W)
               )
   ddr (
        .clk(clk),
        .rst(rst),

        .s_axil_awaddr(M_AXI_AWADDR),
        .s_axil_awprot(M_AXI_AWPROT),
        .s_axil_awvalid(M_AXI_AWVALID),
        .s_axil_awready(M_AXI_AWREADY),

        .s_axil_wdata(M_AXI_WDATA),
        .s_axil_wstrb(M_AXI_WSTRB),
        .s_axil_wvalid(M_AXI_WVALID),
        .s_axil_wready(M_AXI_WREADY),

        .s_axil_bresp(M_AXI_BRESP),
        .s_axil_bvalid(M_AXI_BVALID),
        .s_axil_bready(M_AXI_BREADY),

        .s_axil_araddr(M_AXI_ARADDR),
        .s_axil_arprot(M_AXI_ARPROT),
        .s_axil_arvalid(M_AXI_ARVALID),
        .s_axil_arready(M_AXI_ARREADY),

        .s_axil_rdata(M_AXI_RDATA),
        .s_axil_rresp(M_AXI_RRESP),
        .s_axil_rvalid(M_AXI_RVALID),
        .s_axil_rready(M_AXI_RREADY)
        );

   initial begin

`ifdef VCD
      $dumpfile("iob2axi.vcd");
      $dumpvars;
`endif

      // Global reset of FPGA
      #100;

      clk = 1;
      rst = 0;

      valid = 0;
      addr = 0;
      wdata = 0;
      wstrb = 0;

      // Global reset
      #(clk_per+1);
      rst = 1;

      #clk_per;
      rst = 0;

      // Write
      #clk_per;
      valid = 1;
      addr = 0;
      wdata = 1;
      wstrb = -1;

      i = 0;
      while (i < 10) begin
         if (ready) begin
            addr = ++i*4;
            wdata = 2*i+1;

            if (i == 10) begin
               valid = 0;
               wstrb = 0;
            end
         end

         #clk_per;
      end

      // Read
      #clk_per;
      valid = 1;
      addr = 0;

      i = 0;
      while (i < 10) begin
         if (ready) begin
            if (rdata != 2*i+1) begin
               $display("Fail");
               $finish;
            end

            addr = ++i*4;

            if (i == 10) begin
               valid = 0;
            end
         end

         #clk_per;
      end

      valid = 0;

      $display("Test completed successfully");
      $finish;
   end

   //
   // Clocks
   //

   // system clock
   always #(clk_per/2) clk = ~clk;

endmodule

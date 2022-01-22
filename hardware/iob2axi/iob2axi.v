`timescale 1ns/1ps

module iob2axi #
  (
   parameter ADDR_W = 32,
   parameter DATA_W = 32
   )
  (
   input                 clk,
   input                 rst,

   // Native interface
   input                 valid,
   input [ADDR_W-1:0]    addr,
   input [DATA_W-1:0]    wdata,
   input [DATA_W/8-1:0]  wstrb,
   output [DATA_W-1:0]   rdata,
   output                ready,

   // AXI4-lite interface
   // Master Interface Write Address
   output [ADDR_W-1:0]   M_AXI_AWADDR,
   output [2:0]          M_AXI_AWPROT,
   output                M_AXI_AWVALID,
   input                 M_AXI_AWREADY,

   // Master Interface Write Data
   output [DATA_W-1:0]   M_AXI_WDATA,
   output [DATA_W/8-1:0] M_AXI_WSTRB,
   output                M_AXI_WVALID,
   input                 M_AXI_WREADY,

   // Master Interface Write Response
   input [1:0]           M_AXI_BRESP,
   input                 M_AXI_BVALID,
   output                M_AXI_BREADY,

   // Master Interface Read Address
   output [ADDR_W-1:0]   M_AXI_ARADDR,
   output [2:0]          M_AXI_ARPROT,
   output                M_AXI_ARVALID,
   input                 M_AXI_ARREADY,

   // Master Interface Read Data 
   input [DATA_W-1:0]    M_AXI_RDATA,
   input [1:0]           M_AXI_RRESP,
   input                 M_AXI_RVALID,
   output                M_AXI_RREADY
   );

   // Read not write
   wire                  rnw = (|wstrb)? 1'b0: 1'b1;

   // Transaction errors
   wire                  wr_err = M_AXI_BVALID & M_AXI_BRESP[1];
   wire                  rd_err = M_AXI_RVALID & M_AXI_RRESP[1];

   // Posedge detection
   wire                  M_AXI_AWREADY_pos = M_AXI_AWREADY & ~M_AXI_AWREADY_reg;
   wire                  M_AXI_ARREADY_pos = M_AXI_ARREADY & ~M_AXI_ARREADY_reg;
   wire                  M_AXI_WREADY_pos = M_AXI_WREADY & ~M_AXI_WREADY_reg;
   wire                  M_AXI_RVALID_pos = M_AXI_RVALID & ~M_AXI_RVALID_reg;
   wire                  M_AXI_BVALID_pos = M_AXI_BVALID & ~M_AXI_BVALID_reg;

   reg                   M_AXI_AWREADY_reg;
   reg                   M_AXI_ARREADY_reg;
   reg                   M_AXI_WREADY_reg;
   reg                   M_AXI_RVALID_reg;
   reg                   M_AXI_BVALID_reg;

   reg                   en_aw;
   reg                   en_ar;
   reg                   en_w;
   reg                   en_r;
   reg                   en_b;

   assign M_AXI_AWPROT = 3'b010;
   assign M_AXI_ARPROT = 3'b010;

   assign M_AXI_BREADY = 1'b1;
   assign M_AXI_RREADY = 1'b1;

   assign M_AXI_AWVALID = (rnw | ~en_aw)? 1'b0 : valid;
   assign M_AXI_ARVALID = (rnw & en_ar)? valid : 1'b0;

   assign M_AXI_AWADDR = addr;
   assign M_AXI_ARADDR = addr;

   assign M_AXI_WVALID = (rnw | ~en_w)? 1'b0 : valid;

   assign rdata = M_AXI_RDATA;
   assign M_AXI_WDATA = wdata;
   assign M_AXI_WSTRB = wstrb;

   assign ready = ready_int & ~wr_err & ~rd_err;

   wire ready_int = (~en_aw & ~en_w & ~en_b) |
                    (~en_ar & ~en_r);

   always @ (posedge clk) begin
      if (rst) begin
         M_AXI_AWREADY_reg <= 1'b0;
         M_AXI_ARREADY_reg <= 1'b0;
         M_AXI_WREADY_reg <= 1'b0;
         M_AXI_RVALID_reg <= 1'b0;
         M_AXI_BVALID_reg <= 1'b0;
      end else begin
         M_AXI_AWREADY_reg <= M_AXI_AWREADY;
         M_AXI_ARREADY_reg <= M_AXI_ARREADY;
         M_AXI_WREADY_reg <= M_AXI_WREADY;
         M_AXI_RVALID_reg <= M_AXI_RVALID;
         M_AXI_BVALID_reg <= M_AXI_BVALID;
      end
   end

   always @ (posedge clk) begin
      if (ready_int | rst) begin
         en_aw <= 1'b1;
         en_ar <= 1'b1;
         en_w <= 1'b1;
         en_r <= 1'b1;
         en_b <= 1'b1;
      end else begin
         if (M_AXI_AWREADY_pos) begin
            en_aw <= 1'b0;
         end 
         if (M_AXI_ARREADY_pos) begin
            en_ar <= 1'b0;
         end 
         if (M_AXI_WREADY_pos) begin
            en_w <= 1'b0;
         end 
         if (M_AXI_RVALID_pos) begin
            en_r <= 1'b0;
         end 
         if (M_AXI_BVALID_pos) begin
            en_b <= 1'b0;
         end
      end
   end

endmodule

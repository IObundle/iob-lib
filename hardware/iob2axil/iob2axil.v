`timescale 1ns / 1ps


module iob2axil #
  (
   parameter AXIL_ADDR_W = 32, // Width of address bus in bits
   parameter AXIL_DATA_W = 32  // Width of data bus in bits
   )
   (
    input                        clk,
    input                        rst,

    //
    // AXI-4 lite master interface
    //
`include "axil_m_port.vh"

    //
    // Native slave interface
    //
    input                        valid_i,
    input [AXIL_ADDR_W-1:0]      addr_i,
    input [AXIL_DATA_W-1:0]      wdata_i,
    input [AXIL_DATA_W/8-1:0]    wstrb_i,
    output reg [AXIL_DATA_W-1:0] rdata_o,
    output                       ready_o
    );

   assign axil_awaddr_o = addr_i;
   assign axil_araddr_o = addr_i;
   assign axil_wdata_o  = wdata_i;
   assign axil_wstrb_o  = wstrb_i;

   // AXI IDs
   assign axil_awid_o = `AXI_ID_W'd0;
   assign axil_wid_o  = `AXI_ID_W'd0;
   assign axil_arid_o = `AXI_ID_W'd0;

   // Protection types
   assign axil_awprot_o = `AXI_PROT_W'd2;
   assign axil_arprot_o = `AXI_PROT_W'd2;

   // Quality of services
   assign axil_awqos_o = `AXI_QOS_W'd0;
   assign axil_arqos_o = `AXI_QOS_W'd0;

   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         rdata_o <= {AXIL_DATA_W{1'b0}};
      end else begin
         rdata_o <= axil_rdata_i;
      end
   end

   wire                          wr = valid_i & |wstrb_i;
   wire                          rd = valid_i & ~|wstrb_i;
   reg                           wr_reg, rd_reg;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         wr_reg <= 1'b0;
         rd_reg <= 1'b0;
      end else begin
         wr_reg <= wr;
         rd_reg <= rd;
      end
   end

   reg                           awvalid_ack;
   assign axil_awvalid_o = (wr | wr_reg) & ~awvalid_ack;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         awvalid_ack <= 1'b0;
      end else if (axil_awvalid_i & axil_awready_i) begin
         awvalid_ack <= 1'b1;
      end else if (axil_bvalid_i) begin
         awvalid_ack <= 1'b0;
      end
   end

   reg                           wvalid_ack;
   assign axil_wvalid_o = (wr | wr_reg)  & ~wvalid_ack;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         wvalid_ack <= 1'b0;
      end else if (axil_wvalid_i & axil_wready_i) begin
         wvalid_ack <= 1'b1;
      end else begin
         wvalid_ack <= 1'b0;
      end
   end

   assign axil_bready_o = 1'b1;

   reg                           axil_rvalid_reg;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         axil_rvalid_reg <= 1'b0;
      end else begin
         axil_rvalid_reg <= axil_rvalid_i;
      end
   end

   reg                           arvalid_ack;
   assign axil_arvalid_o = (rd | rd_reg) & ~arvalid_ack;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         arvalid_ack <= 1'b0;
      end else if (axil_arvalid_i & axil_arready_i) begin
         arvalid_ack <= 1'b1;
      end else if (axil_rvalid_i | axil_rvalid_reg) begin
         arvalid_ack <= 1'b0;
      end
   end

   reg                           rready_ack;
   assign axil_rready_o = (rd | rd_reg) & ~rready_ack;
   always @(posedge clk_i, posedge rst_i) begin
      if (rst_i) begin
         rready_ack <= 1'b0;
      end else if (axil_rvalid_i & axil_rready_i) begin
         rready_ack <= 1'b1;
      end else begin
         rready_ack <= 1'b0;
      end
   end

   assign ready_o = axil_bvalid_i | rready_ack;

endmodule

`timescale 1ns / 1ps


//
// IOb slave interface to APB master interface
//

module iob2apb #(
   parameter APB_ADDR_W = 32,          // APB address bus width in bits
   parameter APB_DATA_W = 32,          // APB data bus width in bits
   parameter ADDR_W     = APB_ADDR_W,  // IOb address bus width in bits
   parameter DATA_W     = APB_DATA_W   // IOb data bus width in bits
) (
   // IOb slave interface
   `include "iob_s_port.vh"

   // APB master interface
   `include "iob_apb_m_port.vh"

   // Global signals
   `include "iob_clkenrst_port.vh"
);

   //APB outputs
   reg [1-1:0] apb_sel_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) sel_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(apb_sel_nxt),
      .data_o(apb_sel_o)
   );

   reg [1-1:0] apb_enable_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) enable_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(apb_enable_nxt),
      .data_o(apb_enable_o)
   );

   reg [ADDR_W-1:0] apb_addr_nxt;
   iob_reg #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
   ) addr_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(apb_addr_nxt),
      .data_o(apb_addr_o)
   );

   reg [(DATA_W/8)-1:0] apb_wstrb_nxt;
   iob_reg #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
   ) wstrb_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(apb_wstrb_nxt),
      .data_o(apb_wstrb_o)
   );

   reg [1-1:0] apb_write_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) write_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(apb_write_nxt),
      .data_o(apb_write_o)
   );

   reg [DATA_W-1:0] apb_wdata_nxt;
   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) wdata_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(apb_wdata_nxt),
      .data_o(apb_wdata_o)
   );

   //IOb outputs
   reg [1-1:0] iob_ready_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1)
   ) ready_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(iob_ready_nxt),
      .data_o(iob_ready_o)
   );

   reg [1-1:0] iob_rvalid_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) rvalid_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(iob_rvalid_nxt),
      .data_o(iob_rvalid_o)
   );

   reg [DATA_W-1:0] iob_rdata_nxt;
   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
   ) rdata_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(iob_rdata_nxt),
      .data_o(iob_rdata_o)
   );

   wire [1-1:0] pc;
   reg  [1-1:0] pc_nxt;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(0)
   ) access_reg (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .data_i(pc_nxt),
      .data_o(pc)
   );

   always @* begin

      pc_nxt         = pc + 1'b1;

      apb_sel_nxt    = apb_sel_o;
      apb_enable_nxt = apb_enable_o;
      apb_addr_nxt   = apb_addr_o;
      apb_write_nxt  = apb_write_o;
      apb_wstrb_nxt  = apb_wstrb_o;
      apb_wdata_nxt  = apb_wdata_o;

      iob_rdata_nxt  = iob_rdata_o;
      iob_rvalid_nxt = 1'd0;
      iob_ready_nxt  = iob_ready_o;


      case (pc)
         0: begin
            if (!iob_avalid_i)  //wait for iob request
               pc_nxt = pc;
            else begin  // sample iob signals and initiate apb transaction
               apb_addr_nxt  = iob_addr_i;
               apb_write_nxt = (iob_wstrb_i != 0);
               apb_wstrb_nxt = iob_wstrb_i;
               apb_wdata_nxt = iob_wdata_i;
               apb_sel_nxt   = 1'b1;

               iob_ready_nxt = 1'b0;
            end
         end
         default: begin
            apb_enable_nxt = 1'b1;
            if (!apb_ready_i)  //wait until apb interface is ready
               pc_nxt = pc;
            else begin  //sample apb response, assert rvalid and finish transaction
               iob_rdata_nxt  = apb_rdata_i;
               iob_rvalid_nxt = 1'b1;
               iob_ready_nxt  = 1'b1;
               pc_nxt         = 1'd0;
               apb_sel_nxt    = 1'b0;
               apb_enable_nxt = 1'b0;
            end
         end
      endcase
   end


endmodule

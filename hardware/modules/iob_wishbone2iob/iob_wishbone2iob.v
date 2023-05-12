`timescale 1ns / 1ps

module iob_wishbone2iob #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32
) (
    input wire clk_i,
    input wire cke_i,
    input wire arst_i,

    // Wishbone interface
    input  wire [  ADDR_W-1:0] wb_addr_i,
    input  wire [DATA_W/8-1:0] wb_select_i,
    input  wire                wb_we_i,
    input  wire                wb_cyc_i,
    input  wire                wb_stb_i,
    input  wire [  DATA_W-1:0] wb_data_i,
    output wire                wb_ack_o,
    output wire                wb_error_o,
    output wire [  DATA_W-1:0] wb_data_o,

    // IOb interface
    output wire                iob_avalid_o,
    output wire [  ADDR_W-1:0] iob_address_o,
    output wire [  DATA_W-1:0] iob_wdata_o,
    output wire [DATA_W/8-1:0] iob_wstrb_o,
    input  wire                iob_rvalid_i,
    input  wire [  DATA_W-1:0] iob_rdata_i,
    input  wire                iob_ready_i
);

   // IOb auxiliar wires
   wire                valid;
   wire [DATA_W/8-1:0] wstrb;
   wire [  DATA_W-1:0] rdata_r;
   // Wishbone auxiliar wire
   wire [  ADDR_W-1:0] wb_addr_r;
   wire [  DATA_W-1:0] wb_data_r;
   wire [  DATA_W-1:0] wb_data_mask;

   // Logic
   assign iob_avalid_o = (valid) & (~iob_ready_i);
   assign iob_address_o = wb_addr_i;
   assign iob_wdata_o = wb_data_i;
   assign iob_wstrb_o = wstrb;

   assign valid = wb_stb_i & wb_cyc_i;
   assign wstrb = wb_we_i ? wb_select_i : 4'h0;

   assign wb_data_o = (iob_ready_i ? iob_rdata_i : rdata_r) & (wb_data_mask);
   assign wb_ack_o = iob_ready_i;
   assign wb_error_o = 1'b0;

   assign wb_data_mask = {
      {8{wb_select_i[3]}}, {8{wb_select_i[2]}}, {8{wb_select_i[1]}}, {8{wb_select_i[0]}}
   };
   iob_reg_re #(DATA_W, 0) iob_reg_data_o (
      clk_i,
      arst_i,
      cke_i,
      1'b0,
      iob_ready_i,
      iob_rdata_i,
      rdata_r
   );


endmodule

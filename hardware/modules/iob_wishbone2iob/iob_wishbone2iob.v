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
  wire avalid;
  wire avalid_r;
  wire [DATA_W/8-1:0] wstrb;
  wire [DATA_W-1:0] rdata_r;
  // Wishbone auxiliar wire
  wire [ADDR_W-1:0] wb_addr_r;
  wire [DATA_W-1:0] wb_data_r;
  wire [DATA_W-1:0] wb_data_mask;

  // Logic
  assign iob_avalid_o = (avalid) & (~wb_ack_o);  // (avalid)^(wb_ack_o); should also work
  assign iob_address_o = wb_addr_i;
  assign iob_wdata_o = wb_data_i;
  assign iob_wstrb_o = wstrb;

  assign avalid = wb_stb_i & wb_cyc_i;
  assign wstrb = wb_we_i ? wb_select_i : 4'h0;
  iob_reg_re #(1, 0) iob_reg_avalid (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),
      .rst_i(1'b0),
      .en_i(1'b1),
      .data_i(iob_avalid_o),
      .data_o(avalid_r)
  );

  assign wb_data_o = (iob_rdata_i) & (wb_data_mask);
  assign wb_ack_o = (iob_rvalid_i) & (avalid_r);

  assign wb_data_mask = {
    {8{wb_select_i[3]}}, {8{wb_select_i[2]}}, {8{wb_select_i[1]}}, {8{wb_select_i[0]}}
  };

endmodule

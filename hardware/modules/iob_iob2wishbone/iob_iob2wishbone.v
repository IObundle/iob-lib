`timescale 1ns / 1ps

module iob_iob2wishbone #(
    parameter ADDR_W     = 32,
    parameter DATA_W     = 32,
    parameter READ_BYTES = 4
) (
    input wire clk_i,
    input wire cke_i,
    input wire arst_i,

    // IOb interface
    input  wire                iob_avalid_i,
    input  wire [  ADDR_W-1:0] iob_addr_i,
    input  wire [  DATA_W-1:0] iob_wdata_i,
    input  wire [DATA_W/8-1:0] iob_wstrb_i,
    output wire                iob_rvalid_o,
    output wire [  DATA_W-1:0] iob_rdata_o,
    output wire                iob_ready_o,

    // Wishbone interface
    output wire [  ADDR_W-1:0] wb_addr_o,
    output wire [DATA_W/8-1:0] wb_select_o,
    output wire                wb_we_o,
    output wire                wb_cyc_o,
    output wire                wb_stb_o,
    output wire [  DATA_W-1:0] wb_data_o,
    input  wire                wb_ack_i,
    input  wire [  DATA_W-1:0] wb_data_i
);

  localparam RB_MASK = {1'b0, {READ_BYTES{1'b1}}};

  // IOb auxiliar wires
  wire [  ADDR_W-1:0] address_r;
  wire [  DATA_W-1:0] wdata_r;
  wire                rvalid;
  wire                rvalid_r;
  wire                ready;
  wire                ready_r;
  // Wishbone auxiliar wire
  wire [  DATA_W-1:0] wb_data_r;
  wire [DATA_W/8-1:0] wb_select;
  wire [DATA_W/8-1:0] wb_select_r;
  wire                wb_we;
  wire                wb_we_r;

  // Logic
  assign wb_addr_o = iob_avalid_i ? iob_addr_i : address_r;
  assign wb_data_o = iob_avalid_i ? iob_wdata_i : wdata_r;
  assign wb_select_o = iob_avalid_i ? wb_select : wb_select_r;
  assign wb_we_o = iob_avalid_i ? wb_we : wb_we_r;
  assign wb_cyc_o = wb_stb_o;
  assign wb_stb_o = iob_avalid_i;

  assign wb_select = wb_we ? iob_wstrb_i : (RB_MASK) << (iob_addr_i[1:0]);
  assign wb_we = |iob_wstrb_i;

  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_we (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (iob_avalid_i),
      .data_i(wb_we),
      .data_o(wb_we_r)
  );
  iob_reg_re #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_addr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (iob_avalid_i),
      .data_i(iob_addr_i),
      .data_o(address_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
  ) iob_reg_iob_data (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (iob_avalid_i),
      .data_i(iob_wdata_i),
      .data_o(wdata_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
  ) iob_reg_strb (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (iob_avalid_i),
      .data_i(wb_select),
      .data_o(wb_select_r)
  );

  assign iob_rvalid_o = rvalid_r;  // This has to be verified and very probably fixed :)
  assign rvalid = (~iob_avalid_i) | (wb_ack_i);
  assign iob_rdata_o = wb_data_r;
  assign iob_ready_o = ready_r;
  assign ready = (wb_ack_i) & (~wb_we);
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_rvalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(rvalid),
      .data_o(rvalid_r)
  );
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_ready (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(ready),
      .data_o(ready_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
  ) iob_reg_wb_data (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(wb_data_i),
      .data_o(wb_data_r)
  );


endmodule

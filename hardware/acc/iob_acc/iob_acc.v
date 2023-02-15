`timescale 1ns / 1ps

module iob_acc
  #(
    parameter DATA_W = 21,
    parameter RST_VAL = {DATA_W{1'b0}}
  )
  (
    input               clk_i,
    input               arst_i,
    input               cke_i,

    input               rst_i,
    input               en_i,

    input [DATA_W-1:0]  incr_i,
    output [DATA_W-1:0] data_o
  );

  wire [DATA_W-1:0]    data;
  assign data = data_o + incr_i;

  iob_reg_re #(DATA_W, RST_VAL) reg0
  (
    .clk_i(clk_i),
    .arst_i(arst_i),
    .cke_i(cke_i),

    .rst_i(rst_i),
    .en_i(en_i),

    .data_i(data),
    .data_o(data_o)
  );

endmodule

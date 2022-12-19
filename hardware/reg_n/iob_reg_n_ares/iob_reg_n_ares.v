`timescale 1ns / 1ps

module iob_reg_n_ares
  #(
    parameter DATA_W = 0,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,
    input                   en_i,
    input                   sen_i,
    input [DATA_W-1:0]      data_i,
    output reg [DATA_W-1:0] data_o
    );

   wire [DATA_W-1:0]    data;
   assign data = sen_i? data_i: data_o;

   iob_reg_n_are #(DATA_W, RST_VAL) reg0 (clk_i, arst_i, rst_i, en_i, data, data_o);

endmodule

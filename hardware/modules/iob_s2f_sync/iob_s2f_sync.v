`timescale 1ns / 1ps

module iob_s2f_sync
  #(
    parameter DATA_W = 21,
    parameter RST_VAL = {DATA_W{1'b0}}
  )
  (
    input               clk_i,
    input               arst_i,
    input               cke_i,

    input               rst_i,

    input               ld_i,
    input [DATA_W-1:0]  ld_val_i,

    input [DATA_W-1:0]  data_i,
    output [DATA_W-1:0] data_o
  );

  wire [DATA_W-1:0]    data1;
  wire [DATA_W-1:0]    data2;
  wire [DATA_W-1:0]    sync;
  
  assign data1 = ld_i? ld_val_i: data_i;
  assign data2 = ld_i? ld_val_i: sync;

  iob_reg_r #(DATA_W, RST_VAL) reg0
  (
    .clk_i(clk_i),
    .arst_i(arst_i),
    .cke_i(cke_i),

    .rst_i(rst_i),

    .data_i(data1),
    .data_o(sync)
  );

  iob_reg_r #(DATA_W, RST_VAL) reg1
  (
    .clk_i(clk_i),
    .arst_i(arst_i),
    .cke_i(cke_i),

    .rst_i(rst_i),

    .data_i(data2),
    .data_o(data_o)
  );

endmodule

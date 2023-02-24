`timescale 1ns / 1ps

module iob_modcnt
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

    input [DATA_W-1:0]  mod_i,
    output [DATA_W-1:0] data_o
  );

  wire ld_count = data_o == mod_i;
  wire [DATA_W-1:0] ld_vall = {DATA_W{1'b0}};

  iob_counter_ld #(DATA_W, RST_VAL) cnt0
  (
    .clk_i(clk_i),
    .arst_i(arst_i),
    .cke_i(cke_i),

    .rst_i(rst_i),
    .en_i(en_i),

    .ld_i(ld_count),
    .ld_val_i(ld_vall),

    .data_o(data_o)
  );

endmodule

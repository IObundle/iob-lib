`timescale 1ns / 1ps

module iob_modcnt_ld
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (

    input               clk_i,
    input               arst_i,
    input               rst_i,
    input               en_i,

    input               ld_i,
    input [DATA_W-1:0]  ld_val_i,

    input [DATA_W-1:0]  mod_i,

    output [DATA_W-1:0] data_o
    );

   wire                 cnt_rst;
   assign cnt_rst = rst_i | ((data_o == mod_i) & ((~ld_i) & en_i));
   
   iob_counter_ld #(DATA_W, RST_VAL) cnt0 (clk_i, arst_i, cnt_rst, en_i, ld_i, ld_val_i, data_o);
   
endmodule
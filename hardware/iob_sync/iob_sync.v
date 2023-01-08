`timescale 1ns / 1ps

module iob_sync
  #(
    parameter DATA_W = 0,
    parameter RST_VAL = 0
    )
  (
   input               clk_i,
   input               arst_i,
   input               cke_i,
   input [DATA_W-1:0]  signal_i,
   output [DATA_W-1:0] signal_o
   );

   wire [DATA_W-1:0]   sync;

   iob_reg #(DATA_W, RST_VAL) reg0
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),

      .data_i(signal_i),
      .data_o(sync)
      );

   iob_reg #(DATA_W, RST_VAL) reg1
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),

      .data_i(sync),
      .data_o(signal_o)
      );

endmodule

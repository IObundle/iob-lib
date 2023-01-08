`timescale 1ns / 1ps

module iob_f2s_1bit_sync
  (
   input  clk_i,
   input  cke_i,
   input  i,
   output o
   );

   wire [1:0] sync;
   wire [1:0] data;
   assign data = {sync[0], 1'b0};

   iob_reg #(2, 1) reg0
     (
      .clk_i(clk_i),
      .arst_i(i),
      .cke_i(cke_i),

      .data_i(data),
      .data_o(sync)
      );

   assign o = sync[1];

endmodule

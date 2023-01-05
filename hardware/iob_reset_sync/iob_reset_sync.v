`timescale 1ns / 1ps

module iob_reset_sync
  (
   input  clk_i,
   input  arst_i,
   input  cke_i,
   output rst_o
   );

   wire [1:0] sync_reg;
   wire [1:0] data;
   assign data = {sync_reg[0], 1'b0};

   iob_reg #(2, 1) reg0
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),

      .data_i(data),
      .data_o(sync_reg)
      );

   assign rst_o = sync_reg[1];

endmodule

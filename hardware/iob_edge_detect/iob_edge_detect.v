`timescale 1ns / 1ps

module iob_edge_detect
  #(
    parameter RST_VAL = 0
    )
  (
   input  clk_i,
   input  arst_i,
   input  bit_i,
   output detected_o
   );

   reg bit_i_reg;
   always @(posedge clk_i, posedge arst_i)
     if (arst_i)
       bit_i_reg <= RST_VAL;
     else
       bit_i_reg <= bit_i;

   assign detected_o = bit_i & ~bit_i_reg;

endmodule

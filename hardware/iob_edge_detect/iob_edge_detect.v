`timescale 1ns / 1ps

module iob_edge_detect
  #(
    parameter RST_VAL = 0
    )
  (
   input  clk,
   input  arst,
   input  bit_in,
   output detected
   );

   reg bit_in_reg;
   always @(posedge clk, posedge arst)
     if (arst)
       bit_in_reg <= RST_VAL;
     else
       bit_in_reg <= bit_in;

   assign detected = bit_in & ~bit_in_reg;

endmodule

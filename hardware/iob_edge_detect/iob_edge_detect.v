`timescale 1ns / 1ps

module iob_edge_detect
  (
   input  clk,
   input  rst,
   input  bit_in,
   output detected
   );

   reg bit_in_reg;
   always @(posedge clk, posedge rst)
     if (rst)
       bit_in_reg <= 1'b0;
     else
       bit_in_reg <= bit_in;

   assign detected = bit_in & ~bit_in_reg;

endmodule

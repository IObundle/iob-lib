`timescale 1ns / 1ps

module iob_pulse_detect
  (
   input  clk,
   input  arst,
   input  bit_in,
   output detected
   );

   reg bit_in_reg;
   always @(posedge clk, posedge arst)
     if (arst)
       bit_in_reg <= 1'b0;
     else if (bit_in)
       bit_in_reg <= 1'b1;

   assign detected = bit_in | bit_in_reg;

endmodule

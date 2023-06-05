`timescale 1ns / 1ps

/*
 Description: returns the position of the 1 in the input vector (one-hot)
*/

module iob_encoder #(
    parameter W = 21
) (
   input [W-1:0]              unencoded_i,
   output reg [$clog2(W)-1:0] encoded_o
   );

   integer                  i;
   
   always @(*) begin
      encoded_o = {$clog2(W){1'b0}};
      for (i=0; i<W; i=i+1) begin
         if(unencoded_i[i]) begin
            encoded_o = i;
         end
      end
   end
   
endmodule

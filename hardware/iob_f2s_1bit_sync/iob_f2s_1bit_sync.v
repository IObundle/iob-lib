`timescale 1ns / 1ps

module iob_f2s_1bit_sync
  (
   input  clk_i,
   input  i,
   output o
   );

   reg [1:0] sync;
   always @(posedge clk_i, posedge i) begin
      if (i) begin
         sync <= 2'b11;
      end else begin
         sync <= {sync[0], 1'b0};
      end
   end

   assign o = sync[1];

endmodule

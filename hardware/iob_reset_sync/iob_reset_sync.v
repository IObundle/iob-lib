`timescale 1ns / 1ps

module iob_reset_sync
  (
   input  clk,
   input  arst,
   output rst_out
   );

   reg [1:0] sync_reg;
   always @(posedge clk, posedge arst) begin
      if (arst) begin
         sync_reg <= 2'b11;
      end else begin
         sync_reg <= {sync_reg[0], 1'b0};
      end
   end

   assign rst_out = sync_reg[1];

endmodule

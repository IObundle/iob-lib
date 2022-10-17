`timescale 1ns / 1ps

module iob_reset_sync
  (
   input  clk_i,
   input  arst_i,
   output rst_o
   );

   reg [1:0] sync_reg;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         sync_reg <= 2'b11;
      end else begin
         sync_reg <= {sync_reg[0], 1'b0};
      end
   end

   assign rst_o = sync_reg[1];

endmodule

`timescale 1ns / 1ps

module iob_sync
  #(
    parameter DATA_W = 0,
    parameter RST_VAL = 0
    )
  (
   input                   clk_i,
   input                   arst_i,
   input                   en_i,
   input [DATA_W-1:0]      signal_i,
   output reg [DATA_W-1:0] signal_o
   );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   reg [DATA_W-1:0]        sync_reg;

   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         sync_reg <= RST_VAL_INT;
         signal_o <= RST_VAL_INT;
      end else if (en_i) begin
         sync_reg <= signal_i;
         signal_o <= sync_reg;
      end
   end
   
endmodule

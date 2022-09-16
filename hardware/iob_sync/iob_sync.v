`timescale 1ns / 1ps

module iob_sync
  #(
    parameter DATA_W = 0,
    parameter RST_VAL = 0
    )
  (
   input                   clk,
   input                   arst,
   input [DATA_W-1:0]      signal_in,
   output reg [DATA_W-1:0] signal_out
   );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   reg [DATA_W-1:0]        sync_reg;

   always @(posedge clk, posedge arst) begin
      if (arst) begin
         sync_reg <= RST_VAL_INT;
         signal_out <= RST_VAL_INT;
      end else begin
         sync_reg <= signal_in;
         signal_out <= sync_reg;
      end
   end
   
endmodule

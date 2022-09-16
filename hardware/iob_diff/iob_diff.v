`timescale 1ns / 1ps

module iob_diff
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input               clk,
    input               arst,
    input               rst,

    input               en,
    input [DATA_W-1:0]  data_in,
    output [DATA_W-1:0] data_out
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   reg [DATA_W-1:0]     data_in_reg;
   always @(posedge clk, posedge arst) begin
      if (arst) begin
         data_in_reg <= RST_VAL_INT;
      end else if (rst) begin
         data_in_reg <= RST_VAL_INT;
      end else if (en) begin
         data_in_reg <= data_in;
      end
   end

   assign data_out = data_in - data_in_reg;

endmodule

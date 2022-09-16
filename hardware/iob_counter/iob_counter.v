`timescale 1ns / 1ps

module iob_counter
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input                   clk,
    input                   arst,
    input                   rst,

    input                   ld,
    input [DATA_W-1:0]      ld_val,

    input                   en,
    output reg [DATA_W-1:0] data_out
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   always @(posedge clk, posedge arst) begin
      if (arst) begin
         data_out <= RST_VAL_INT;
      end else if (rst) begin
         data_out <= RST_VAL_INT;
      end else if (ld) begin
         data_out <= ld_val;
      end else if (en) begin
         data_out <= data_out + 1'b1;
      end
   end

endmodule

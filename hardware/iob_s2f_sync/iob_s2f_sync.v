`timescale 1ns / 1ps

module iob_s2f_sync
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

    input [DATA_W-1:0]      data_in,
    output reg [DATA_W-1:0] data_out
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   reg [DATA_W-1:0]         sync;
   always @(posedge clk, posedge arst) begin
      if (arst) begin
         sync <= RST_VAL_INT;
         data_out <= RST_VAL_INT;
      end else if (rst) begin
         sync <= RST_VAL_INT;
         data_out <= RST_VAL_INT;
      end else if (ld) begin
         sync <= ld_val;
         data_out <= ld_val;
      end else begin
         sync <= data_in;
         data_out <= sync;
      end
   end

endmodule

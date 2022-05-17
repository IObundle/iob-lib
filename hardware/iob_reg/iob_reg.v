`timescale 1ns / 1ps

module iob_reg
  #(
    parameter DATA_W = 32
    )
   (
    input                   clk,

    input                   arst,
    input [DATA_W-1:0]      arst_val,

    input                   rst,
    input [DATA_W-1:0]      rst_val,

    input                   en,
    input [DATA_W-1:0]      data_in,
    output reg [DATA_W-1:0] data_out
    );

   always @(posedge clk, posedge arst) begin
      if (arst) begin
         data_out <= arst_val;
      end else if (rst) begin
         data_out <= rst_val;
      end else if (en) begin
         data_out <= data_in;
      end
   end

endmodule

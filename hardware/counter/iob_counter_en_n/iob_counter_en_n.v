`timescale 1ns / 1ps

module iob_counter_en_n
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,

    input                   en_i,
    input                   sen_i,

    output reg [DATA_W-1:0] data_o
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   wire [DATA_W-1:0]        data;
   assign data = sen_i? data_o + 1'b1: data_o;

   always @(negedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_o <= RST_VAL_INT;
      end else if (rst_i) begin
         data_o <= RST_VAL_INT;
      end else if (en_i) begin
         data_o <= data;
      end
   end

endmodule

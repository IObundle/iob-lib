`timescale 1ns / 1ps

module iob_diff
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input               clk_i,
    input               arst_i,
    input               rst_i,

    input               en_i,
    input [DATA_W-1:0]  data_i,
    output [DATA_W-1:0] data_o
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   reg [DATA_W-1:0]     data_i_reg;
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_i_reg <= RST_VAL_INT;
      end else if (rst_i) begin
         data_i_reg <= RST_VAL_INT;
      end else if (en_i) begin
         data_i_reg <= data_i;
      end
   end

   assign data_o = data_i - data_i_reg;

endmodule

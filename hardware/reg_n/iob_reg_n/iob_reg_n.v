`timescale 1ns / 1ps

module iob_reg_n
  #(
    parameter DATA_W = 0,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   cke_i,

    input [DATA_W-1:0]      data_i,
    output reg [DATA_W-1:0] data_o
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;
   
   always @(negedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_o <= RST_VAL_INT;
      end else if (cke_i) begin
         data_o <= data_i;
      end
   end

endmodule

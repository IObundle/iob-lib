`timescale 1ns / 1ps

module iob_reg_n_are
  #(
    parameter DATA_W = 0,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,
    input                   en_i,
    input [DATA_W-1:0]      data_i,
    output reg [DATA_W-1:0] data_o
    );
   
   always @(negedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_o <= RST_VAL[DATA_W-1:0];
      end else if (rst_i) begin
         data_o <= RST_VAL[DATA_W-1:0];
      end else if (en_i) begin
         data_o <= data_i;
      end
   end

endmodule

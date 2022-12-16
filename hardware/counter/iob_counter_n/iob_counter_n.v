`timescale 1ns / 1ps

module iob_counter_n
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,
    input                   en_i,

    output reg [DATA_W-1:0] data_o
    );

   always @(negedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_o <= RST_VAL[DATA_W-1:0];
      end else if (rst_i) begin
         data_o <= RST_VAL[DATA_W-1:0];
      end else if (en_i) begin
         data_o <= data_o + 1'b1;
      end
   end

endmodule

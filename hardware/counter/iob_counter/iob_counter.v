`timescale 1ns / 1ps

module iob_counter
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   en_i,

    input                   rst_i,
    input                   sen_i,

    output reg [DATA_W-1:0] data_o
    );

   // prevent width mismatch
   localparam [DATA_W-1:0] RST_VAL_INT = RST_VAL;

   always @(posedge clk_i, posedge arst_i)
     if (arst_i)
       data_o <= RST_VAL_INT;
     else if (en_i)
       if (rst_i)
         data_o <= RST_VAL_INT;
       else if (sen_i)
         data_o <= data_o + 1'b1;

endmodule

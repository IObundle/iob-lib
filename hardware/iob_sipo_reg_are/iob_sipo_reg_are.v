`timescale 1ns / 1ps

module iob_sipo_reg_are
  #(
    parameter DATA_W = 32
    )
   (

    input               clk_i,
    input               arst_i,

    input               en_i,

    // parallel input
    input               s_i,

    // serial output
    output [DATA_W-1:0] p_o
    );

   reg [DATA_W-1:0]  data_reg;
   
   always @(posedge clk_i, posedge arst_i)
     if (arst_i)
       data_reg <= 1'b0;
     else if (en)
       data_reg <= (data_reg << 1) | s_i;

   assign p_o = data_reg;
   
endmodule

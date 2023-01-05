`timescale 1ns / 1ps

module iob_piso_reg
  #(
    parameter DATA_W = 32
    )
   (

    input              clk_i,
    input              arst_i,
    input              cke_i,

    // parallel input
    input              ld_i,
    input [DATA_W-1:0] p_i,

    // serial output
    output             s_o
    );

   wire [DATA_W-1:0]   data_reg;
   wire [DATA_W-1:0]   data;
   assign data = ld_i? p_i: data_reg << 1'b1;

   iob_reg #(DATA_W, 0) reg0
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),

      .data_i(data),
      .data_o(data_reg)
      );

   assign s_o = data_reg[DATA_W-1];
   
endmodule

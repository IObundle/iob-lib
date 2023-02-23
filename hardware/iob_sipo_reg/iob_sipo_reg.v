`timescale 1ns / 1ps

module iob_sipo_reg
  #(
    parameter DATA_W = 21
  )
  (

    input               clk_i,
    input               arst_i,
    input               cke_i,

    //serial input
    input               s_i,

    //parallel output
    output [DATA_W-1:0] p_o
  );

  wire [DATA_W-1:0]   data;
  assign data = {p_o[DATA_W-2:0], s_i};

  iob_reg #(DATA_W, 0) reg0
  (
    .clk_i(clk_i),
    .arst_i(arst_i),
    .cke_i(cke_i),

    .data_i(data),
    .data_o(p_o)
  );
  
endmodule

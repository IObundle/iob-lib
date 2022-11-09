`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_mux
  #(
    parameter DATA_W = 0,
    parameter N = 0
    )
   (
    input [N*DATA_W-1:0] data_i,
    input [$clog2(N)-1:0] sel_i,
    output [DATA_W-1:0]  data_o
    );

   `IOB_WIRE(data_int, N*DATA_W)
   assign data_int = data_i >> (sel*DATA_W);
   assign data_o = data_int[DATA_W-1:0];

endmodule

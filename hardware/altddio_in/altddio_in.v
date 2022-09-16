/*****************************************************************************

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module altddio_in
  #(
    parameter DATA_W = 1
    )
  (
   input                   clk,
   input [DATA_W-1:0]      data_in,
   output reg [DATA_W-1:0] data_out_l,
   output reg [DATA_W-1:0] data_out_h
   );

   always @(posedge clk)
     data_out_h <= data_in;

   always @(negedge clk)
     data_out_l <= data_in;

endmodule

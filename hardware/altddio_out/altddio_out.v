/*****************************************************************************

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module altddio_out
  #(
    parameter DATA_W = 1
    )
  (
   input               clk,
   input [DATA_W-1:0]  data_in_l,
   input [DATA_W-1:0]  data_in_h,
   output [DATA_W-1:0] data_out
   );

   reg [DATA_W-1:0]    data_in_l_reg;
   reg [DATA_W-1:0]    data_in_h_reg;

   always @(posedge clk)
     data_in_h_reg <= data_in_h;

   always @(negedge clk)
     data_in_l_reg <= data_in_l;

   assign data_out = clk? data_in_h_reg: data_in_l_reg;

endmodule

/*****************************************************************************

  Description: Clock Wrapper

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/


`timescale 1ns / 1ps
`include "iob_lib.vh"

module clk_wrapper
  (
   `INPUT(clk_in),
   `OUTPUT(clk_out)
   );

   assign clk_out = clk_in;
   
endmodule

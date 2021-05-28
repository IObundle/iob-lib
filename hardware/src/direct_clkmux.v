/*****************************************************************************

  Description: Clock Wrapper

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/


`timescale 1ns / 1ps
`include "iob_lib.vh"

module clkmux
  (
   `INPUT(clk_in0, 1),
   `INPUT(clk_in1, 1),
   `INPUT(clk_sel, 1),
   `OUTPUT(clk_out, 1)
   );

   assign clk_out = clk_sel ? clk_in1 : clk_in0;
   
endmodule

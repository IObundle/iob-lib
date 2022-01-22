/*****************************************************************************

  Description: Clock Wrapper

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/


`timescale 1ns / 1ps
`include "iob_lib.vh"

module clkbuf
  (
   `INPUT(clk_in, 1),
   `OUTPUT(clk_out, 1)
   );

   BUFG BUFG_inst(.I(clk_in),.O(clk_out));
   
endmodule

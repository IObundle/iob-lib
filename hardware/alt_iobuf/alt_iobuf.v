/*****************************************************************************

  Description: IOB_INOUT 3-State Buffer

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module alt_iobuf
  (
   input  i,
   input  oe_i,
   output o,
   inout  io
   );

   assign io = oe_i? i : 1'bz;
   assign o = io;

endmodule

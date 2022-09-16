/*****************************************************************************

  Description: IOB_INOUT 3-State Buffer

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module iob_iobuf
  (
   input  I,  // from core
   input  T,  // from core: tristate control
   input  N,  // from core: inversion control
   output O,  // to core
   inout  IO, // to device IO
   );

   wire   O_int;

`ifdef XILINX
   IOBUF IOBUF_inst
     (
      .I(I),
      .T(T),
      .O(O_int),
      .IO(IO)
      );
`else
   assign IO = T? 1'bz : I;
   assign O_int = IO;
`endif

   assign O = N^O_int;

endmodule

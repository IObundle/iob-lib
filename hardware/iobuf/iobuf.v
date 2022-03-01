/*****************************************************************************

  Description: INOUT 3-State Buffer

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

`include "iob_lib.vh"

module iobuf
  (
   `IOB_INPUT(I, 1), //from core
   `IOB_INPUT(T, 1), //from core: tristate control
   `IOB_INPUT(N, 1), //from core: inversion control
   `IOB_OUTPUT(O, 1),//to core
   `INOUT(IO, 1) //to device IO
   );

`ifdef XILINX
   IOBUF IOBUF_inst
     (
      .I(I),
      .T(T),
      .O(O),
      .IO(IO)
      );
`else
   assign IO = T? 1'bz : I;
`endif

   assign O = N^IO;

endmodule

/*****************************************************************************

  Description: INOUT 3-State Buffer

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps
`include "iob_lib.vh"

module iobuf
  (
   `INPUT(I, 1), //from core
   `INPUT(T, 1), //from core: tristate control
   `INPUT(N, 1), //from core: inversion control
   `OUTPUT(O, 1),//to core
   `INOUT(IO, 1) //to device IO
   );

   assign IO = T? 1'bz : I;
   assign O = N^IO;

endmodule

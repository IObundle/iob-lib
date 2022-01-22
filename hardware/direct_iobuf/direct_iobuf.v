/*****************************************************************************

  Description: INOUT 3-State Buffer

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps
`include "iob_lib.vh"

module iobuf
  (
   `INPUT(I, 1), //input from FPGA
   `INPUT(T, 1), //(1) disables I (0) enables I
   `OUTPUT(O, 1), //output into FPGA
   `INOUT(IO, 1) //IO to/from device pad
   );

   assign IO = T? 1'bz : I;
   assign O = IO;

endmodule

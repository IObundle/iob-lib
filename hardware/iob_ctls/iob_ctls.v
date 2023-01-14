/*****************************************************************************

  Description: IOB_CTLS Count Trailing/Leading Symbols

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module iob_ctls
  #(
    parameter N = 0,
    parameter TYPE = 0, //trailing (0), leading (1)
    parameter SYMBOL = 0 //search zeros (0), search ones (1) 
    )
  (
   input [N-1:0]        data_i,
   output [$clog2(N):0] count_o
   );

   //invert if searching zeros or not
   wire [N-1:0]         data_int1 = !SYMBOL? ~data_i: data_i;

   // reverse if lading symbols or not
   wire [N-1:0]         data_int2;
   iob_reverse
     #(N)
   reverse0
     (
      .data_i(data_int1),
      .data_o(data_int2)
      );
   
   wire [N-1:0]         data_int3 = TYPE? data_int2: data_int1;

   //normalized to count trailing ones
   reg found_zero;
   reg [$clog2(N):0] count;   
   integer           i;
   
   always @* begin
      found_zero = 0;
      count = 0;
      for (i=0; i < N; i=i+1) begin
         found_zero = found_zero | ~data_int3[i];
         if (!found_zero)
           count=count+1;
      end
   end
   
   assign count_o = count;
   
endmodule

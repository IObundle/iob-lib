/*****************************************************************************

  Description: IOB_CTLS Count Trailing/Leading Symbols

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module iob_ctls #(
    parameter N      = 21,
    parameter MODE   = 0,   //trailing (0), leading (1)
    parameter SYMBOL = 0    //search zeros (0), search ones (1) 
) (
    input  [      N-1:0] data_i,
    output [$clog2(N):0] count_o
);

   //invert if searching zeros or not
   wire [N-1:0] data_int1;
   generate
      if (SYMBOL == 0) assign data_int1 = data_i;
      else assign data_int1 = ~data_i;
   endgenerate

   // reverse if lading symbols or not
   wire [N-1:0] data_int2;
   generate
      if (MODE == 1) begin : g_reverse
         iob_reverse #(N) reverse0 (
            .data_i(data_int1),
            .data_o(data_int2)
         );
      end else begin : g_noreverse
         assign data_int2 = data_int1;
         assign data_int2 = data_int1;
      end
   endgenerate

   //normalized to count trailing zeros
   reg     [$clog2(N):0] count;
   integer               pos;

   always_comb begin
      count = 0;

      for (pos = 0; pos < N; pos = pos + 1)
      if ((data_int2[pos] == 1'd0) && (count == pos)) count = pos + 1;
   end

   assign count_o = count;

endmodule

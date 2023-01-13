/*****************************************************************************

  Description: IOB_CTLS Count Trailing/Leading Symbols

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module iob_ctls
  #(
    parameter N = 0,
    parameter MODE = 0, // zero for leading, one for trailing
    parameter SYMBOL = 0
    )
  (
   input [N-1:0]        data_i,
   output [$clog2(N):0] count_o
   );

   wire [N-1:0]         data_rev;
   generate
      if (MODE) begin
         assign data_rev = data_i;
      end else begin
         iob_reverse
           #(N)
         reverse0
           (
            .data_i(data_i),
            .data_o(data_rev)
            );
      end
   endgenerate

   wire [N-1:0]         data_n;
   assign data_n = SYMBOL? data_rev: ~data_rev;

   wire [(N*$clog2(N))-1:0] idx;
   wire [(N*$clog2(N))-1:0] count;
   wire [N-1:0]           found;
   wire [N:0]             ones;
   assign ones[0] = data_n[0];

   genvar                 i;
   generate
      for (i=0; i < N; i=i+1) begin: lead_ones_gen
         assign ones[i+1] = data_n[i] & ones[i];
         assign found[i] = (~ones[i+1]) & ones[i];
         assign idx[((N*$clog2(N))-(i*$clog2(N)))-1 -: $clog2(N)] = found[i]? i[$clog2(N)-1:0]: 1'b0;
         assign count[((N*$clog2(N))-(i*$clog2(N)))-1 -: $clog2(N)] = (i == 0)? idx[((N*$clog2(N))-(i*$clog2(N)))-1 -: $clog2(N)]:
                                                                          idx[((N*$clog2(N))-(i*$clog2(N)))-1 -: $clog2(N)] | count[((N*$clog2(N))-((i-1)*$clog2(N)))-1 -: $clog2(N)];
      end
   endgenerate

   assign count_o = ones[N]? N: {1'b0, count[$clog2(N)-1:0]};

endmodule

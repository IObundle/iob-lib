/*****************************************************************************

  Description: IOB_CTLS Count Trailing/Leading Symbols

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module iob_ctls
  #(
    parameter N = 0,
    parameter TYPE = 0, // zero for leading, one for trailing
    parameter SYMBOL = 0
    )
  (
   input [N-1:0]        data_i,
   output [$clog2(N):0] count_o
   );

   wire [N-1:0]         data_rev;
   generate
      if (TYPE) begin
         iob_reverse
           #(N)
         reverse0
           (
            .data_i(data_i),
            .data_o(data_rev)
            );
      end else begin
         assign data_rev = data_i;
      end
   endgenerate

   wire [N-1:0]         data_n;
   assign data_n = SYMBOL? data_rev: ~data_rev;

   // Compute ones word
   wire [N-1:0]         ones;
   assign ones[N-1] = data_n[N-1];

   genvar               i;
   generate
      for (i=N-2; i >= 0; i=i-1) begin: lead_ones_gen
         assign ones[i] = data_n[i] & ones[i+1];
      end
   endgenerate

   // Sum ones
   wire [$clog2(N):0]   array [N-1:0];
   assign array[0] = {{(N-1){1'b0}}, ones[0]};

   genvar               j;
   generate
      for (j=0; j < N-1; j=j+1) begin: sum_ones_gen
         assign array[j+1] = array[j] + ones[j+1];
      end
   endgenerate

   assign count_o = array[N-1];

endmodule

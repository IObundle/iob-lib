module iob_prio_enc
  #(
    parameter N = 0;
    )
  (
   input [N-1:0] data_i;
   output [$clog2(N)] sel_o;
   );

   genvar             i, j;
   generate
      j = 1;
      for (i=0; i<N; i=i+1)
        if(j)
          if(data_i[i]) begin
             assign sel_o = i;
             j=0;
          end
   endgenerate
   
endmodule

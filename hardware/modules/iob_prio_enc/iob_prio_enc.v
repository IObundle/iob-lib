`timescale 1ns / 1ps


module iob_prio_enc #(
    parameter W = 21
) (
   input [ W-1:0]         unencoded_i,
   output [$clog2(W)-1:0] encoded_o
);

   wire [W-1:0]                        filter1;
   wire [W-1:0]                        filter2;

   assign filter1[0] = unencoded_i[0];
   assign filter2[0] = unencoded_i[0];
   
   genvar                              i;
   
   generate
      for(i=1; i<W; i=i+1) begin: g_loop
         assign filter1[i] = unencoded_i[i] | filter1[i-1];
         assign filter2[i] = filter1[i] & ~filter1[i-1];
      end
   endgenerate

   iob_encoder 
     #(
       .W(W)
       ) 
   iob_encoder_inst 
     (
      .unencoded_i(filter2),
      .encoded_o(encoded_o)
      );

endmodule

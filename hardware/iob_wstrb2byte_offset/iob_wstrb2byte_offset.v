`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_wstrb2byte_offset
  #(
    parameter N = 0
    )
   (
    input [N-1:0]          wstrb_i,
    output [$clog2(N)-1:0] wstrb2byte_offset_o
    );

   integer                 i;
   
   `IOB_VAR(cnt, $clog2(N))
   `IOB_VAR(found, 1)
   
   `IOB_COMB begin
      found = 1'd0;
      cnt = 1'd0;
      for(i=0; i<N; i=i+1)
        if((!found) && wstrb_i[i]) begin
           found = 1'b1;
           cnt = i;
        end
   end

   `IOB_VAR2WIRE(cnt, wstrb2byte_offset_o)

endmodule

`timescale 1ns / 1ps

module iob_reverse
  #(
    parameter DATA_W = 0
    )
   (
    input [DATA_W-1:0]  data_i,
    output [DATA_W-1:0] data_o
    );

   genvar               i;
   generate
      for (i=0; i < DATA_W; i=i+1) begin : reverse
         assign data_o[i] = data_i[DATA_W-1-i];
      end
   endgenerate

endmodule

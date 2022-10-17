`timescale 1ns/1ps

// Convert gray encoding to binary
module iob_gray2bin
  #(
    parameter DATA_W = 4
    )
   (
    input [DATA_W-1:0]  gr_i,
    output [DATA_W-1:0] bin_o
    );

   genvar               i;

   generate
      for(i=0; i < DATA_W; i=i+1) begin : gen_bin
         assign bin_o[i] = ^gr_i[DATA_W-1:i];
      end
   endgenerate

endmodule

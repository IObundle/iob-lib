`timescale 1ns / 1ps

// Note: Not tested!

module iob_reverse
  #(
    parameter DATA_W = 32
    )
   (
    input [DATA_W-1:0]      data_i,
    output reg [DATA_W-1:0] data_o
    );

   integer i;

   always @* begin
      for (i=0; i < DATA_W; i=i+1) begin : reverse
         data_o[i] = data_i[DATA_W-1-i];
      end
   end

endmodule

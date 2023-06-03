`timescale 1ns / 1ps
module iob_encoder_tb;

   localparam W=8;

   reg [W-1:0] data_i = 1;
   wire [$clog2(W)-1:0] data_o;

   integer i;

   initial begin
      $dumpfile("uut.vcd");
      $dumpvars();

      for(i=0; i<W; i=i+1) begin
         #10 data_i = 1<<i;
      end
      #10 $finish();
   end
   
   iob_encoder #(.W(W)) iob_encoder_inst (
      .unencoded_i(data_i),
      .encoded_o(data_o)
   );

   
endmodule

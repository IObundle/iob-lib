`timescale 1ns / 1ps
module iob_prio_enc_tb;

   localparam W=8;

   reg [W-1:0] data_i = 1;
   wire [$clog2(W)-1:0] data_o;

   integer i;

   initial begin
      $dumpfile("uut.vcd");
      $dumpvars();

      for(i=0; i<2**W; i=i+1) begin
         #10 data_i = i;
      end
      #10 $finish();
   end
   
   iob_prio_enc #(.W(W)) iob_prio_enc_inst (
      .unencoded_i(data_i),
      .encoded_o(data_o)
   );
   
endmodule


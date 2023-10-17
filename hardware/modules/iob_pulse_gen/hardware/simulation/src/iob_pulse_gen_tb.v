`timescale 1ns / 1ps

module iob_pulse_gen_tb;

   localparam START    = 0;
   localparam DURATION = 10;

   reg clk = 0;
   reg rst = 0;
   reg start_i = 0;
   wire pulse_o;

   iob_pulse_gen #(
      .START   (START),
      .DURATION(DURATION)
   ) 
   pulse_gen 
     (
      .clk_i   (clk),
      .arst_i  (rst),
      .cke_i   (1'b1),
      .start_i (start_i),
      .pulse_o (pulse_o)
      );

   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      #11 rst = 1;
      #10 rst = 0;

      #10 start_i = 1;
      #10 start_i = 0;

      #100 $finish;
   end // initial begin

   always begin
      #5 clk = ~clk;
   end // always begin

endmodule



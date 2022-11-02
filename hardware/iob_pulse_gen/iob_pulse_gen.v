`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_pulse_gen
  #(
    parameter START=0,
    parameter DURATION=0
    )
  (
   input  clk_i,
   input  arst_i,
   input  restart_i,
   output pulse_o
   );

   //restart detect
   `IOB_WIRE(restart_detect, 1)
   iob_pulse_detect pulse_detect (clk_i, arst_i, restart_i, restart_detect);

   //counter
   `IOB_WIRE(cnt_en, 1)
   localparam WIDTH = $clog2(START+DURATION+2);
   `IOB_WIRE(cnt, WIDTH)   

   //counter enable
   assign cnt_en = restart_detect & (cnt <= (START+DURATION));

   //counter
   iob_counter #(WIDTH,0) cnt0 
     (clk_i, arst_i, restart_i, cnt_en, 1'b0, {WIDTH{1'b0}}, cnt);

   //pulse
   assign pulse_o = cnt_en & |cnt;
   
endmodule

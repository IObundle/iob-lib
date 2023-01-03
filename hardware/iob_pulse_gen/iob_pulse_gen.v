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
   input  en_i,
   input  start_i,
   output pulse_o
   );

   //start detect
   `IOB_WIRE(start_detected, 1)
   `IOB_WIRE(start_detected_nxt, 1)
   assign start_detected_nxt = start_detected | start_i;
   
   iob_reg_ae #(1,0) start_detected_inst (clk_i, arst_i, en_i, start_detected_nxt, start_detected);

   
   //counter
   `IOB_WIRE(cnt_en, 1)
   localparam WIDTH = $clog2(START+DURATION+2);
   `IOB_WIRE(cnt, WIDTH)   

   //counter enable
   assign cnt_en = start_detected & (cnt <= (START+DURATION));

   //counter
   iob_counter #(WIDTH,0) cnt0 (clk_i, arst_i, en_i, start_i, cnt_en, cnt);

   //pulse
   assign pulse_o = cnt_en & |cnt;
   
endmodule

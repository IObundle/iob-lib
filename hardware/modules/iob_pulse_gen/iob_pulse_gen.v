`timescale 1ns / 1ps


module iob_pulse_gen #(
    parameter START=0,
    parameter DURATION=0
    ) (
    input  clk_i,
    input  arst_i,
    input  cke_i,
    input  start_i,
    output pulse_o
    );

   localparam WIDTH = $clog2(START+DURATION+2);

   //start detect
   wire [1-1:0] start_detected;
   wire [1-1:0] start_detected_nxt;
   assign start_detected_nxt = start_detected | start_i;
   
   iob_reg #
   (
    .DATA_W (1),
    .RST_VAL (0),
    .CLKEDGE ("posedge")
   )
   start_detected_inst
   (
    .clk_i(clk_i),
    .arst_i(arst_i),
    .cke_i(cke_i),
    .data_i(start_detected_nxt),
    .data_o(start_detected)
   );

   //counter
   wire [1-1:0] cnt_en;
   wire [WIDTH-1:0] cnt;   

   //counter enable
   assign cnt_en = start_detected & (cnt <= (START+DURATION));

    //counter
    iob_counter #
      (
       .DATA_W(WIDTH),
       .RST_VAL({WIDTH{1'b0}})
       )
    cnt0 (
        .clk_i(clk_i),
        .arst_i(arst_i),
        .cke_i(cke_i),
        .rst_i(start_i),
        .en_i(cnt_en),
        .data_o(cnt)
        );

   //pulse
   assign pulse_o = cnt_en & |cnt;
   
endmodule

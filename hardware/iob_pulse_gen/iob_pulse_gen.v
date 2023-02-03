`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_pulse_gen #(
    parameter START=5,
    parameter DURATION=5
    ) (
    input  clk_i,
    input  arst_i,
    input  cke_i,
    input  start_i,
    output pulse_o
    );

    localparam WIDTH = (START+DURATION)==1? 1: $clog2(START+DURATION);

    wire [WIDTH-1:0] cnt;
    wire pulse_start;
    wire pulse_end;

    //counter
    iob_counter #(WIDTH,0)
    cnt0 (
        .clk_i(clk_i),
        .arst_i(arst_i),
        .cke_i(cke_i),
        .rst_i(start_i),
        .en_i(pulse_end),
        .data_o(cnt)
        );

    assign pulse_start = (cnt >= START);
    assign pulse_end = (cnt <= (START+DURATION));
    assign pulse_o = pulse_start&pulse_end;

endmodule
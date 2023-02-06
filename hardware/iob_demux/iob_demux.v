`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_demux #(
    parameter DATA_W = 0,
    parameter N = 0
    ) (
    `IOB_INPUT(sel_i, $clog2(N)+($clog2(N)==0)),
    `IOB_INPUT(data_i, DATA_W),
    `IOB_OUTPUT(data_o, N*DATA_W)
    );

    //integer i;
    //always @* begin
    //    for (i=0; i<N; i=i+1)
    //        if(i == sel_i) begin
    //            data_o[i*DATA_W += DATA_W] = data_i;
    //        end else begin
    //            data_o[i*DATA_W += DATA_W] = {(DATA_W){1'b0}};
    //        end
    //end

    reg [N*DATA_W-1:0] data_int;
    assign data_o = data_int << (sel_i*DATA_W);
    // Alternative
    always @* begin
        data_int = {(N*DATA_W){1'b0}};
        data_int[DATA_W-1:0] = data_i;
    end

endmodule

`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_demux #(
    parameter DATA_W = 21,
    parameter N = 21
    ) (
    `IOB_INPUT(sel_i, ($clog2(N)+($clog2(N)==0))),
    `IOB_INPUT(data_i, DATA_W),
    `IOB_OUTPUT(data_o, (N*DATA_W))
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

    //Alternative
    assign data_o = {{((N-1)*DATA_W){1'b0}}, data_i} << (sel_i*DATA_W);

endmodule

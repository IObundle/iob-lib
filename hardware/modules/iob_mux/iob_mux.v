`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_mux
  #(
    parameter DATA_W = 21,
    parameter N = 21
  )
  (
    `IOB_INPUT(sel_i, ($clog2(N)+($clog2(N)==0))),
    `IOB_INPUT(data_i, (N*DATA_W)),
    `IOB_OUTPUT_VAR(data_o, DATA_W)
  );

  integer i;
  always @* begin
    data_o = {DATA_W{1'b0}};
    for (i=0; i<N; i=i+1) begin : gen_mux
      if (i==sel_i)
        data_o = data_i[i*DATA_W+:DATA_W];
    end
  end

endmodule

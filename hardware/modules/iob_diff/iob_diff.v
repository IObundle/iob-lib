`timescale 1ns / 1ps

module iob_diff #(
    parameter DATA_W  = 32,
    parameter RST_VAL = 0
) (
    input clk_i,
    input arst_i,
    input cke_i,

    input rst_i,

    input  [DATA_W-1:0] data_i,
    output [DATA_W-1:0] data_o
);

   wire [DATA_W-1:0] data_i_reg;
   iob_reg_r #(DATA_W, RST_VAL) reg0 (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),

      .rst_i(rst_i),

      .data_i(data_i),
      .data_o(data_i_reg)
   );

   assign data_o = data_i - data_i_reg;

endmodule

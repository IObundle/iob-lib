`timescale 1ns / 1ps
`include "iob_lib.vh"

module sync
  #(
    parameter WIDTH = 0,
    parameter RST_VAL = 0
    )
  (
   `INPUT(clk, 1),
   `INPUT(rst, 1),
   `INPUT(signal_in, WIDTH),
   `OUTPUT_VAR(signal_out, WIDTH)
   );

   `VAR(sync_reg, WIDTH)
   `REG_AR(clk, rst, 1'b0, sync_reg, signal_in)
   `REG_AR(clk, rst, 1'b0, signal_out, sync_reg)

endmodule

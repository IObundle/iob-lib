`timescale 1ns / 1ps

`include "iob_lib.vh"

module clkbuf
  (
   `INPUT(clk_in, 1),
   `OUTPUT(clk_out, 1)
   );

`ifdef XILINX
   BUFG BUFG_inst
     (
      .I(clk_in),
      .O(clk_out)
      );
`else
   assign clk_out = clk_in;
`endif

endmodule

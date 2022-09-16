`timescale 1ns / 1ps

module iob_clkbuf
  (
   input  clk_in,
   output clk_out
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

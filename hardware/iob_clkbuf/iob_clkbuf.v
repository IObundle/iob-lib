`timescale 1ns / 1ps

module iob_clkbuf
  (
   input  clk_i,
   output clk_o
   );

`ifdef XILINX
   BUFG BUFG_inst
     (
      .I(clk_i),
      .O(clk_o)
      );
`else
   assign clk_o = clk_i;
`endif

endmodule

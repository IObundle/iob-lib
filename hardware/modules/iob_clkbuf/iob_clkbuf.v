`timescale 1ns / 1ps

module iob_clkbuf
  (
   input  clk_i,
   input  n_i,
   output clk_o
   );

   wire   clk_int;

`ifdef XILINX
   BUFG BUFG_inst
     (
      .I(clk_i),
      .O(clk_int)
      );
`else
   assign clk_int = clk_i;
`endif

   assign clk_o = n_i^clk_int;

endmodule

/*****************************************************************************

  Description: Clock Wrapper

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module iob_clkmux
  (
   input  clk_in0,
   input  clk_in1,
   input  clk_sel,
   output clk_out
   );

`ifdef XILINX
   BUFGMUX
     #(
       .CLK_SEL_TYPE("ASYNC")
	   )
   BUFGMUX_inst
     (
	  .I0(clk_in0), 
	  .I1(clk_in1), 
	  .S(clk_sel), 
	  .O(clk_out)
	  );
`else
   assign clk_out = clk_sel ? clk_in1 : clk_in0;
`endif

endmodule

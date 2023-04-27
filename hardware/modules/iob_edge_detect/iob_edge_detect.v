`timescale 1ns / 1ps

module iob_edge_detect #
  (
   parameter CLKEDGE = "posedge"
   )
  (
   input  clk_i,
   input  arst_i,
   input  cke_i,
   input  bit_i,
   output detected_o
   );

  wire   bit_i_reg;

  iob_reg #
    (
     .DATA_W(1), 
     .RST_VAL(1'b1),
     .CLKEDGE(CLKEDGE)
     )
  reg0
    (
     .clk_i(clk_i),
     .arst_i(arst_i),
     .cke_i(cke_i),
     
     .data_i({bit_i}),
     .data_o(bit_i_reg)
     );
  
  assign detected_o = bit_i & ~bit_i_reg;

endmodule

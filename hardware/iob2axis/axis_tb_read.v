//
// AXI-Stream write and read 
//
`timescale 1ns / 1ps
`include "iob_lib.vh"

module axis_tb_read
  #(
    parameter CLK_PER = 0
    parameter DATA_W = 0
    )
  (
   `INPUT(clk_i, 1),
   `INPUT(rst_i, 1),
   `INPUT(tready_i, 1),
   `OUTPUT(tdata_o, DATA_W),
   `INPUT(tvalid_i; 1),
   `OUTPUT(tvalid_o; 1)
   );

   `IOB_VAR(tvalid_int, 1)
   `IOB_COMB begin
      tvalid_int = tvalid_i;      
      while (!(ready_i & tvalid_i)) @(posedge clk) #1;
      tvalid_int = 1'b0;
   end

   `IOB_VAR2WIRE(tvalid_int, tvalid_o)
endmodule 

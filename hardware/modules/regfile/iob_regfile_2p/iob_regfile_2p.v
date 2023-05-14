`timescale 1 ns / 1 ps
`include "iob_utils.vh"

module iob_regfile_2p 
  #(
    parameter DATA_W     = 0,
    parameter ADDR_W     = 0
    ) 
(
 input                 clk_i,
 input                 arst_i,
 input                 cke_i,

 // Write Port
 input [ADDR_W-1:0]    waddr_i,
 input                 wen_i,
 input [DATA_W-1:0]    wdata_i,
         
 // Read Port
 input [ADDR_W-1:0]    raddr_i,
 output [DATA_W-1 : 0] rdata_o
 );

   reg [DATA_W-1 : 0]  regfile [2**ADDR_W-1:0];

  genvar i;
   generate
      for (i = 0; i < (2**ADDR_W); i = i + 1) begin : g_regfile_en
         iob_reg_e #(
                     .DATA_W (DATA_W),
                     .RST_VAL({DATA_W{1'b0}}),
                     .CLKEDGE("posedge")
                     ) iob_reg_inst (
                                     .clk_i (clk_i),
                                     .arst_i(arst_i),
                                     .cke_i (cke_i),
                                     .en_i  (wen_i),
                                     .data_i(wdata_i),
                                     .data_o(regfile[i])
                                     );
         assign rdata_o = regfile[raddr_i];
      end
   endgenerate
   
endmodule

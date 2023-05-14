`timescale 1 ns / 1 ps

module iob_regfile_2p_readpar 
  #(
    parameter DATA_W     = 0,
    parameter ADDR_W     = 0
    ) 
(
 input                               clk_i,
 input                               arst_i,
 input                               cke_i,

 // Write Port
 input [ADDR_W-1:0]                  addr_i,
 input                               wen_i,
 input [DATA_W-1:0]                  data_i,
         
 // Read Port
 output [((2**ADDR_W)*DATA_W)-1 : 0] data_o
);

   reg [((2**ADDR_W)*DATA_W)-1 : 0]  regfile;
   wire [((2**ADDR_W)*DATA_W)-1 : 0] data_nxt = data_i << addr_i;
   wire [(2**ADDR_W)-1:0]            en;

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
                                     .data_i(data_nxt[i*DATA_W+:DATA_W]),
                                     .data_o(data_o[i*DATA_W+:DATA_W])
                                     );
      end
   endgenerate

   assign data_o = regfile;
   
endmodule

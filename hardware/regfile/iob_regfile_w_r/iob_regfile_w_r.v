`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_w_r
  #(
    parameter ADDR_W = 0,
    parameter DATA_W = 0,
    parameter ADDR_W_INT = (ADDR_W==0)? 1: ADDR_W,
    parameter DATA_W_INT = (DATA_W==0)? 1: DATA_W
    )
   (
    input                   clk_i,
    input                   arst_i,
    input                   rst_i,
    input                   en_i,

    // Write Port
    input                   we_i,
    input [ADDR_W_INT-1:0]  waddr_i,
    input [DATA_W_INT-1:0]  wdata_i,

    // Read Port
    input [ADDR_W_INT-1:0]  raddr_i,
    output [DATA_W_INT-1:0] rdata_o
    );
   
   wire [DATA_W_INT-1 :0]   regfile [(2**ADDR_W)-1:0];
   wire [(2**ADDR_W_INT)-1:0]    en;

   genvar                          i;
   generate
      for (i=0; i < (2**ADDR_W); i=i+1) begin: register_file
         assign en[i] =  en_i & we_i & (waddr_i==i);
         iob_reg_are #(DATA_W_INT, 0) iob_reg0
             (
              .clk_i(clk_i),
              .arst_i(arst_i),
              .rst_i(rst_i),
              .en_i(en[i]),
              .data_i(wdata_i),
              .data_o(regfile[i])
              );
      end
   endgenerate

   assign rdata_o = regfile[raddr_i];
   
endmodule

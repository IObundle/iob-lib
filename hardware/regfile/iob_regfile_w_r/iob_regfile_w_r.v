`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_w_r
  #(
    parameter ADDR_W = 0,
    parameter WADDR_W_MAX = 0,
    parameter RADDR_W_MAX = 0,
    parameter DATA_W = 0,
    parameter WDATA_W_MAX = 0,
    parameter RDATA_W_MAX = 0
    )
   (
    input                    clk_i,
    input                    arst_i,
    input                    rst_i,
    input                    en_i,

    // Write Port
    input                    we_i,
    input [WADDR_W_MAX-1:0]  waddr_i,
    input [WDATA_W_MAX-1:0]  wdata_i,

    // Read Port
    input [RADDR_W_MAX-1:0]  raddr_i,
    output [RDATA_W_MAX-1:0] rdata_o
    );

   localparam DATA_W_INT = (DATA_W==0)? 1: DATA_W;
                          
   wire [DATA_W_INT-1 :0]    regfile [(2**ADDR_W)-1:0];
   wire [(2**ADDR_W)-1:0]  en;
   wire waddr_in_scope = (waddr_i < (2**ADDR_W));

   genvar                          i;
   generate
      for (i=0; i < (2**ADDR_W); i=i+1) begin: register_file
         if(ADDR_W==0)
           assign en[i] =  en_i & we_i & waddr_in_scope;
         else
           assign en[i] =  en_i & we_i & waddr_in_scope & (waddr_i==i);
         iob_reg_are #(DATA_W_INT, 0) iob_reg0
             (
              .clk_i(clk_i),
              .arst_i(arst_i),
              .rst_i(rst_i),
              .en_i(en[i]),
              .data_i(wdata_i[DATA_W_INT-1:0]),
              .data_o(regfile[i])
              );
      end
   endgenerate

   assign rdata_o = (raddr_i < (2**ADDR_W))? regfile[raddr_i[0+:ADDR_W]]: {RDATA_W_MAX{1'd0}};
   
endmodule

`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_w_rp
  #(
    parameter ADDR_W = 0,
    parameter ADDR_W_MAX = 0,
    parameter DATA_W = 0,
    parameter DATA_W_MAX = 0
    )
   (
    input                          clk_i,
    input                          arst_i,
    input                          rst_i,
    input                          en_i,

    // Write Port
    input                          we_i,
    input [ADDR_W_MAX-1:0]         waddr_i,
    input [DATA_W_MAX-1:0]         wdata_i,

    // Read Port
    output [((2**ADDR_W)*DATA_W)-1 :0] rdata_o
    );

   wire [(2**ADDR_W)-1:0] en;
   wire addr_in_scope = (waddr_i < (2**ADDR_W));

   genvar                          i;
   generate
      for (i=0; i < (2**ADDR_W); i=i+1) begin: register_file
         if(ADDR_W==0)
           assign en[i] = en_i & we_i & addr_in_scope;
         else
           assign en[i] =  en_i & we_i & addr_in_scope & (waddr_i==i);
         iob_reg_are #(DATA_W, 1) iob_reg0
             (
              .clk_i(clk_i),
              .arst_i(arst_i),
              .rst_i(rst_i),
              .en_i(en[i]),
              .data_i(wdata_i[DATA_W-1:0]),
              .data_o(rdata_o[((i+1)*DATA_W)-1-:DATA_W])
              );
      end
   endgenerate

endmodule

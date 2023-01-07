`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_w_rp
  #(
    parameter WADDR_W = 0,
    parameter WDATA_W = 0,
    parameter RDATA_W = 0,
    parameter R = WDATA_W/RDATA_W
    )
   (
    input                              clk_i,
    input                              arst_i,
    input                              cke_i,

    input                              rst_i,

    // Write Port
    input [R-1:0]                      wstrb_i,
    input [WADDR_W-1:0]                waddr_i,
    input [WDATA_W-1:0]                wdata_i,

    // Read Port
    output [((2**WADDR_W)*WDATA_W)-1 :0] rdata_o
    );

   wire [R-1:0]                          wstrb [(2**WADDR_W)-1:0];
   
   genvar                               i, j;
   generate
      for (i=0; i < (2**(WADDR_W-1)); i=i+1) begin: rf_addr
         for (j=0; j < R; j=j+1) begin: rf_slice
            assign wstrb[i][j] = (waddr_i == i) & wstrb_i[j];
            iob_reg_re #(RDATA_W, 1) iob_reg0
              (
               .clk_i(clk_i),
               .arst_i(arst_i),
               .cke_i(cke_i),
               .rst_i(rst_i),
               .en_i(wstrb[i][j]),
               .data_i(wdata_i[j*RDATA_W+:RDATA_W]),
               .data_o(rdata_o[i*WDATA_W+j*RDATA_W+:RDATA_W])
               );
         end
      end
   endgenerate
   
endmodule

`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_w_r
  #(
    parameter WADDR_W = 0,
    parameter WDATA_W = 0,
    parameter RDATA_W = 0,
    parameter R = WDATA_W/RDATA_W,
    parameter RADDR_W = WADDR_W+$clog2(R)
    )
   (
    input                clk_i,
    input                arst_i,
    input                cke_i,
    
    input                rst_i,

    // Write Port
    input [R-1:0]        wstrb_i,
    input [WADDR_W-1:0]  waddr_i,
    input [WDATA_W-1:0]  wdata_i,

    // Read Port
    input [RADDR_W-1:0]  raddr_i,
    output [RDATA_W-1:0] rdata_o
    );
   
   wire [R-1:0]          wstrb [(2**WADDR_W)-1:0];
   wire [((2**WADDR_W)*WDATA_W)-1 :0] regfile;
   
   genvar                            i, j;
   generate
      for (i=0; i < 2**WADDR_W; i=i+1) begin: rf
         for (j=0; j < R; j=j+1) begin: rf_row
            assign wstrb[i][j] = (waddr_i == i) & wstrb_i[j];
            iob_reg_re #(RDATA_W, 0) iob_reg_rf_row_slice
              (
               .clk_i(clk_i),
               .arst_i(arst_i),
               .cke_i(cke_i),
               .rst_i(rst_i),
               .en_i(wstrb[i][j]),
               .data_i(wdata_i[j*RDATA_W+:RDATA_W]),
               .data_o(regfile[i*WDATA_W+j*RDATA_W+:RDATA_W])
               );
         end
      end
   endgenerate

   wire [((2**WADDR_W)*WDATA_W)-1 :0] regf_shifted = regfile >> (RDATA_W*raddr_i);
   
   assign rdata_o = regf_shifted[RDATA_W-1:0];
   
endmodule

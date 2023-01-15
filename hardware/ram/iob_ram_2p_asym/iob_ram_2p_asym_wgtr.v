`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_ram_2p_asym_wgtr
  #(
    parameter W_DATA_W = 0,
    parameter R_DATA_W = 0,
    parameter ADDR_W = 0,//higher ADDR_W (lower DATA_W)
    //determine W_ADDR_W and R_ADDR_W
    parameter MAXDATA_W = `IOB_MAX(W_DATA_W, R_DATA_W),
    parameter MINDATA_W = `IOB_MIN(W_DATA_W, R_DATA_W),
    parameter MINADDR_W = ADDR_W-$clog2(MAXDATA_W/MINDATA_W),//lower ADDR_W (higher DATA_W)
    parameter W_ADDR_W = (W_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W,
    parameter R_ADDR_W = (R_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W,
    //determine the number of blocks N
    parameter R = MAXDATA_W/MINDATA_W
    )
   (
    input                      clk_i,

    //write port
    output [R-1:0]             ext_mem_w_en_o,
    output [(MINDATA_W*R)-1:0] ext_mem_w_data_o,
    output [(MINADDR_W*R)-1:0] ext_mem_w_addr_o,
    //read port
    output                     ext_mem_r_en_o,
    output [(MINADDR_W*R)-1:0] ext_mem_r_addr_o,
    input [(MINDATA_W*R)-1:0]  ext_mem_r_data_i,

    //write port
    input                      w_en_i,
    input [W_ADDR_W-1:0]       w_addr_i,
    input [W_DATA_W-1:0]       w_data_i,
    //read port
    input                      r_en_i,
    input [R_ADDR_W-1:0]       r_addr_i,
    output [R_DATA_W-1:0]      r_data_o
    );

   //symmetric memory block buses
   //write buses
   wire [R-1:0]                en_wr;
   wire [R*MINDATA_W-1:0]      data_wr;
   wire [R*MINADDR_W-1:0]      addr_wr;

   //read buses
   wire [R*MINDATA_W-1:0]      data_rd;
   wire [R*MINADDR_W-1:0]      addr_rd;

   wire [MINDATA_W-1:0]       data_rd_0;
   assign data_rd_0 = data_rd[(R*MINDATA_W)-1 -: MINDATA_W];

   //connect the buses

   //write parallel
   genvar                     j;
   generate
      for (j=0; j < R; j= j+1) begin
         assign en_wr[j] = w_en_i;
         assign data_wr[(R*MINDATA_W)-(j*MINDATA_W)-1 -: MINDATA_W] = w_data_i[(j*MINDATA_W) +: MINDATA_W];
         assign addr_wr[(R*MINADDR_W)-(j*MINADDR_W)-1 -: MINADDR_W] = w_addr_i;
      end
   endgenerate

   //read serial
   genvar                     k;
   generate
      for (k=0; k < R; k= k+1) begin
         assign addr_rd[(R*MINADDR_W)-(k*MINADDR_W)-1 -: MINADDR_W] = r_addr_i[R_ADDR_W-1-:W_ADDR_W];
      end
   endgenerate

   //read address register
   reg [(R_ADDR_W-W_ADDR_W)-1:0] r_addr_lsbs_reg;
   always @(posedge clk_i)
     if (r_en_i)
       r_addr_lsbs_reg <= r_addr_i[(R_ADDR_W-W_ADDR_W)-1:0];

   //read mux
   genvar                     l;
   generate
      for (l=0; l < R; l= l+1) begin
         assign r_data_o = data_rd[(R*MINDATA_W)-(r_addr_lsbs_reg*MINDATA_W)-1 -: MINDATA_W];
      end
   endgenerate

   genvar  p;
   generate
      for(p=0; p < R; p= p+1) begin : ext_mem_interface_gen
         assign ext_mem_w_en_o[p] = en_wr[p];
         assign ext_mem_w_addr_o[(p*MINADDR_W)+:MINADDR_W] = addr_wr[(R*MINADDR_W)-(p*MINADDR_W)-1 -: MINADDR_W];
         assign ext_mem_w_data_o[(p*MINDATA_W)+:MINDATA_W] = data_wr[(R*MINDATA_W)-(p*MINDATA_W)-1 -: MINDATA_W];
         assign ext_mem_r_addr_o[(p*MINADDR_W)+:MINADDR_W] = addr_rd[(R*MINADDR_W)-(p*MINADDR_W)-1 -: MINADDR_W];
         assign data_rd[(R*MINDATA_W)-(p*MINDATA_W)-1 -: MINDATA_W] = ext_mem_r_data_i[(p*MINDATA_W)+:MINDATA_W];
      end
   endgenerate
   assign ext_mem_r_en_o = r_en_i;

endmodule

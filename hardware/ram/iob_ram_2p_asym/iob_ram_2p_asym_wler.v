`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_ram_2p_asym_wler
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

   wire [MINDATA_W-1:0]        data_rd_0;
   assign data_rd_0 = data_rd[R*MINDATA_W-1 -: MINDATA_W];

   //connect the buses
   genvar                      m,q;
   generate

      if (W_DATA_W < R_DATA_W) begin
         //write serial
         for (m=0; m < R; m= m+1) begin
            assign en_wr[m] = w_en_i & (w_addr_i[(W_ADDR_W-R_ADDR_W)-1:0] == m);
            assign data_wr[R*MINDATA_W-m*MINDATA_W-1 -: MINDATA_W] = w_data_i;
            assign addr_wr[R*MINADDR_W-m*MINADDR_W-1 -: MINADDR_W] = w_addr_i[W_ADDR_W-1 -: R_ADDR_W];
         end
         //read parallel
         for (q=0; q < R; q= q+1) begin
            assign addr_rd[R*MINADDR_W-q*MINADDR_W-1 -: MINADDR_W] = r_addr_i;
            assign r_data_o[q*MINDATA_W +: MINDATA_W] = data_rd[R*MINDATA_W-q*MINDATA_W-1 -: MINDATA_W];
         end

      end else begin //W_DATA_W = R_DATA_W
         //write serial
         assign en_wr[0] = w_en_i;
         assign data_wr[R*MINDATA_W-1 -: MINDATA_W] = w_data_i;
         assign addr_wr[R*MINADDR_W-1 -: MINADDR_W] = w_addr_i;
         //read parallel
         assign addr_rd[R*MINADDR_W-1 -: MINADDR_W] = r_addr_i;
         assign r_data_o = data_rd_0;
      end
   endgenerate

   genvar  p;
   generate
      for(p=0; p < R; p= p+1) begin : ext_mem_interface_gen
         assign ext_mem_w_en_o[p] = en_wr[p];
         assign ext_mem_w_addr_o[p*MINADDR_W+:MINADDR_W] = addr_wr[R*MINADDR_W-p*MINADDR_W-1 -: MINADDR_W];
         assign ext_mem_w_data_o[p*MINDATA_W+:MINDATA_W] = data_wr[R*MINDATA_W-p*MINDATA_W-1 -: MINDATA_W];
         assign ext_mem_r_addr_o[p*MINADDR_W+:MINADDR_W] = addr_rd[R*MINADDR_W-p*MINADDR_W-1 -: MINADDR_W];
         assign data_rd[R*MINDATA_W-p*MINDATA_W-1 -: MINDATA_W] = ext_mem_r_data_i[p*MINDATA_W+:MINDATA_W];
      end
   endgenerate
   assign ext_mem_r_en_o = r_en_i;

endmodule

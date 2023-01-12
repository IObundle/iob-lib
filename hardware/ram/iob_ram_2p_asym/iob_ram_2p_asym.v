`timescale 1ns / 1ps
`include "iob_lib.vh"

module iob_ram_2p_asym
  #(
    parameter
    W_DATA_W = 0,
    R_DATA_W = 0,
    ADDR_W = 0,//higher ADDR_W (lower DATA_W)
    //determine W_ADDR_W and R_ADDR_W
    MAXDATA_W = `IOB_MAX(W_DATA_W, R_DATA_W),
    MINDATA_W = `IOB_MIN(W_DATA_W, R_DATA_W),
    MINADDR_W = ADDR_W-$clog2(MAXDATA_W/MINDATA_W),//lower ADDR_W (higher DATA_W)
    W_ADDR_W = (W_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W,
    R_ADDR_W = (R_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W,
    //determine the number of blocks N
    N = MAXDATA_W/MINDATA_W
    )
   (
    input                      clk_i,

    output                     ext_mem_clk_o,
    //write port
    output [N-1:0]             ext_mem_w_en_o,
    output [(MINDATA_W*N)-1:0] ext_mem_w_data_o,
    output [(MINADDR_W*N)-1:0] ext_mem_w_addr_o,
    //read port
    output                     ext_mem_r_en_o,
    output [(MINADDR_W*N)-1:0] ext_mem_r_addr_o,
    input [(MINDATA_W*N)-1:0]  ext_mem_r_data_i,

    //write port
    input                      w_en_i,
    input [W_ADDR_W-1:0]       w_addr_i,
    input [W_DATA_W-1:0]       w_data_i,
    //read port
    input                      r_en_i,
    input [R_ADDR_W-1:0]       r_addr_i,
    output reg [R_DATA_W-1:0]  r_data_o
    );

   //symmetric memory block buses
   //write buses
   reg [N-1:0]                en_wr;
   reg [MINDATA_W-1:0]        data_wr [N-1:0];
   reg [MINADDR_W-1:0]        addr_wr [N-1:0];

   //read buses
   wire [MINDATA_W-1:0]       data_rd [N-1:0];
   reg [MINADDR_W-1:0]        addr_rd [N-1:0];

   wire [MINDATA_W-1:0]       data_rd_0;
   assign data_rd_0 = data_rd[0];

   //connect the buses
   integer j,k,l;
   generate

      if (W_DATA_W > R_DATA_W) begin

         //write parallel
         always @* begin
            for (j=0; j < N; j= j+1) begin
               en_wr[j] = w_en_i;
               data_wr[j] = w_data_i[j*MINDATA_W +: MINDATA_W];
               addr_wr[j] = w_addr_i;
            end
         end

         //read serial
         always @* begin
            for (k=0; k < N; k= k+1) begin
               addr_rd[k] = r_addr_i[R_ADDR_W-1-:W_ADDR_W];
            end
         end

         //read address register
         reg [(R_ADDR_W-W_ADDR_W)-1:0] r_addr_lsbs_reg;
         always @(posedge clk_i)
           if (r_en_i)
             r_addr_lsbs_reg <= r_addr_i[(R_ADDR_W-W_ADDR_W)-1:0];

         //read mux
         always @* begin
            r_data_o = 1'b0;
            for (l=0; l < N; l= l+1) begin
               r_data_o = data_rd[r_addr_lsbs_reg];
            end
         end

      end else  if (W_DATA_W < R_DATA_W) begin
         //write serial
         always @* begin
            for (j=0; j < N; j= j+1) begin
               en_wr[j] = w_en_i & (w_addr_i[(W_ADDR_W-R_ADDR_W)-1:0] == j);
               data_wr[j] = w_data_i;
               addr_wr[j] = w_addr_i[W_ADDR_W-1 -: R_ADDR_W];
            end
         end
         //read parallel
         always @* begin
            r_data_o = 1'b0;
            for (k=0; k < N; k= k+1) begin
               addr_rd[k] = r_addr_i;
               r_data_o[k*MINDATA_W +: MINDATA_W] = data_rd[k];
            end
         end

      end else begin //W_DATA_W = R_DATA_W
         //write serial
         always @* begin
            en_wr[0] = w_en_i;
            data_wr[0] = w_data_i;
            addr_wr[0] = w_addr_i;
         end
         //read parallel
         always @* begin
            addr_rd[0] = r_addr_i;
            r_data_o = data_rd_0;
         end
      end
   endgenerate

   genvar  p;
   generate
      for(p=0; p < N; p= p+1) begin : ext_mem_interface_gen
         assign ext_mem_w_en_o[p] = en_wr[p];
         assign ext_mem_w_addr_o[p*MINADDR_W+:MINADDR_W] = addr_wr[p];
         assign ext_mem_w_data_o[p*MINDATA_W+:MINDATA_W] = data_wr[p];
         assign ext_mem_r_addr_o[p*MINADDR_W+:MINADDR_W] = addr_rd[p];
         assign data_rd[p] = ext_mem_r_data_i[p*MINDATA_W+:MINDATA_W];
      end
   endgenerate
   assign ext_mem_r_en_o = r_en_i;
   assign ext_mem_clk_o = clk_i;

endmodule

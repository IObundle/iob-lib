`timescale 1ns / 1ps

module iob_ram_2p_asym_wler
  #(
    parameter W_DATA_W = 21,
    parameter R_DATA_W = 42,
    parameter ADDR_W = 3,//higher ADDR_W (lower DATA_W)
    parameter R = R_DATA_W/W_DATA_W,
    parameter R_ADDR_W = ADDR_W-$clog2(R),//lower ADDR_W (higher DATA_W)
    parameter W_ADDR_W = ADDR_W
    )
   (
    //write port
    input                 w_en_i,
    input [W_ADDR_W-1:0]  w_addr_i,
    input [W_DATA_W-1:0]  w_data_i,
    //read port
    input                 r_en_i,
    input [R_ADDR_W-1:0]  r_addr_i,
    output [R_DATA_W-1:0] r_data_o,

    //write port
    output [R-1:0]        ext_mem_w_en_o,
    output [R_DATA_W-1:0] ext_mem_w_data_o,
    output [R_ADDR_W-1:0] ext_mem_w_addr_o,

    //read port
    output [R-1:0]        ext_mem_r_en_o,
    output [R_ADDR_W-1:0] ext_mem_r_addr_o,
    input [R_DATA_W-1:0]  ext_mem_r_data_i
    );


   //memory write port
   generate
      if(R==1) begin
         assign ext_mem_w_en_o = w_en_i;
         assign ext_mem_w_data_o = w_data_i;
      end else begin
         assign ext_mem_w_en_o = {{(R-1){1'd0}},w_en_i} << w_addr_i[$clog2(R)-1:0];
         assign ext_mem_w_data_o = {{(R_DATA_W-W_DATA_W){1'd0}},w_data_i} << (w_addr_i[$clog2(R)-1:0]*W_DATA_W);
      end
   endgenerate
   
   assign ext_mem_w_addr_o = w_addr_i[W_ADDR_W-1:$clog2(R)];

   //memory read port
   assign ext_mem_r_en_o = {R{r_en_i}};
   assign ext_mem_r_addr_o = r_addr_i;
   assign r_data_o = ext_mem_r_data_i;
   
endmodule

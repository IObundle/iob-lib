`timescale 1ns / 1ps
`include "iob_utils.vh"


module iob_shift_reg #(
   parameter DATA_W = 21,
   parameter N = 21,
   parameter ADDR_W = $clog2(N)
  
) (
   `include "clk_en_rst_s_port.vs"

   input rst_i,

   //write port
   input                 w_en_i,
   input  [DATA_W-1:0]   w_data_i,
   output                w_full_o,

   //read port
   input                 r_en_i,
   output [DATA_W-1:0] r_data_o,
   output                r_empty_o,

   //memory clock 
   output                 ext_mem_clk_o,
   //memory write port
   output ext_mem_w_en_o,
   output [ADDR_W-1:0] ext_mem_w_addr_o,
   output [DATA_W-1:0] ext_mem_w_data_o,
   //read port
   output ext_mem_r_en_o,
   output [ADDR_W-1:0] ext_mem_r_addr_o,
   input  [DATA_W-1:0] ext_mem_r_data_i
);

   //declare fifo_level
   reg [ADDR_W-1:0] fifo_level;

   //instantiate iob_fifo_sync
   iob_fifo_sync #(
      .DATA_W(DATA_W),
      .N(N),
      .ADDR_W(ADDR_W)
   ) iob_fifo_sync_inst (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .w_en_i(w_en_i),
      .w_data_i(w_data_i),
      .w_full_o(w_full_o),
      .r_en_i(r_en_i),
      .r_data_o(r_data_o),
      .r_empty_o(r_empty_o),
      .ext_mem_clk_o(ext_mem_clk_o),
      .ext_mem_w_en_o(ext_mem_w_en_o),
      .ext_mem_w_addr_o(ext_mem_w_addr_o),
      .ext_mem_w_data_o(ext_mem_w_data_o),
      .ext_mem_r_en_o(ext_mem_r_en_o),
      .ext_mem_r_addr_o(ext_mem_r_addr_o),
      .ext_mem_r_data_i(ext_mem_r_data_i),
      .level_o (fifo_level)
   );
   
endmodule

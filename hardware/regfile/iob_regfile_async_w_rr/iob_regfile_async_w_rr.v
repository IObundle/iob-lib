`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_async_w_rr
  #(
    parameter ADDR_W = 0,
    parameter DATA_W = 0
    )
   (
    // Write Port
    input                   w_clk_i,
    input                   w_arst_i,
    input                   w_en_i,
    input [ADDR_W-1:0]      w_addr_i,
    input [DATA_W-1:0]      w_data_i,

    // Read Port
    input                   r_clk_i,
    input                   r_arst_i,
    input                   r_en_i,
    input [ADDR_W-1:0]      r_addr_i,
    output [DATA_W-1:0]     r_data_o
    );
    
   localparam DATA_W_INT = (DATA_W==0)? 1: DATA_W;

   //write
   `IOB_VARARRAY_2D(regfile_w, (2**ADDR_W), DATA_W)
   `IOB_VARARRAY_2D(regfile_r, (2**ADDR_W), DATA_W)
   
   `IOB_WIRE(en, (2**ADDR_W))
   
   genvar i;
   generate for(i = 0; i < (2**ADDR_W); i = i + 1) begin: register_file
      assign en[i] =  w_en_i & (w_addr_i==i);
      iob_reg_ae #(DATA_W_INT, 0) iob_reg0
          (
           .clk_i(w_clk_i),
           .arst_i(w_arst_i),
           .en_i(en[i]),
           .data_i(w_data_i[DATA_W_INT-1:0]),
           .data_o(regfile_w[i])
           );
      iob_sync #(DATA_W_INT,0) iob_sync_regfile (r_clk_i, r_arst_i, r_en_i, regfile_w[i], regfile_r[i]);   
   end endgenerate
   
   //read
   assign r_data_o = regfile_r[r_addr_i];
   
endmodule

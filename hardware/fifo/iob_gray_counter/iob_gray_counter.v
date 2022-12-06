`timescale 1ns/1ps
`include "iob_lib.vh"

module iob_gray_counter 
  #(
    parameter   W = 1
    )
   (
    input          clk_i,
    input          arst_i,
    input          rst_i,
    input          en_i,
    output [W-1:0] data_o
    );
   
   reg [W-1:0]     bin_counter;
   reg [W-1:0]     bin_counter_nxt;
   reg [W-1:0]     gray_counter;
   reg [W-1:0]     gray_counter_nxt;
   
   `IOB_COMB bin_counter_nxt = bin_counter + 1;
   
   generate 
      if (W > 1) begin
         `IOB_COMB gray_counter_nxt = {bin_counter[W-1], bin_counter[W-2:0] ^ bin_counter[W-1:1]};
      end else begin
         `IOB_COMB gray_counter_nxt = bin_counter;
      end 
   endgenerate
   
   iob_reg_are #(W, 1) bin_counter_reg (clk_i, arst_i, rst_i, en_i, bin_counter_nxt, bin_counter);
   iob_reg_are #(W, 0) gray_counter_reg (clk_i, arst_i, rst_i, en_i, gray_counter_nxt, gray_counter);

   assign data_o = gray_counter;
endmodule

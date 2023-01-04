`timescale 1ns/1ps
`include "iob_lib.vh"

module iob_gray_counter 
  #(
    parameter   W = 1
    )
   (
    input          clk_i,
    input          arst_i,
    input          cke_i,

    input          rst_i,
    output [W-1:0] data_o
    );
   
   wire [W-1:0]     bin_counter;
   wire [W-1:0]     bin_counter_nxt;
   wire [W-1:0]     gray_counter;
   wire [W-1:0]     gray_counter_nxt;
   
   assign bin_counter_nxt = bin_counter + 1'b1;
   
   generate 
      if (W > 1) begin
         assign gray_counter_nxt = {bin_counter[W-1], bin_counter[W-2:0] ^ bin_counter[W-1:1]};
      end else begin
         assign gray_counter_nxt = bin_counter;
      end 
   endgenerate
   
   iob_reg_r #(W, 1) bin_counter_reg
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),

      .rst_i(rst_i),

      .data_i(bin_counter_nxt),
      .data_o(bin_counter)
      );

   iob_reg_r #(W, 0) gray_counter_reg
     (
      .clk_i(clk_i),
      .arst_i(arst_i),
      .cke_i(cke_i),

      .rst_i(rst_i),

      .data_i(gray_counter_nxt),
      .data_o(gray_counter)
     );

   assign data_o = gray_counter;

endmodule

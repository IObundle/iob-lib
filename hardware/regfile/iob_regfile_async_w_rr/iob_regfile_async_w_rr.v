`timescale 1 ns / 1 ps
`include "iob_lib.vh"

module iob_regfile_async_w_rr
  #(
    parameter ADDR_W = 0,
    parameter DATA_W = 0
    )
   (
    // Write Port
    input              w_clk_i,
    input              w_arst_i,
    input              w_en_i,
    input [ADDR_W-1:0] w_addr_i,
    input [DATA_W-1:0] w_data_i,

    // Read Port
    input               r_clk_i,
    input               r_arst_i,
    input               r_en_i,
    input [ADDR_W-1:0]  r_addr_i,
    output reg [DATA_W-1:0] r_data_o
    );

   //write
   `IOB_VARARRAY_2D(regfile, (2**ADDR_W), DATA_W)
   genvar i;
   generate for(i = 0; i < (2**ADDR_W); i = i + 1)
      always @(posedge w_clk_i, posedge w_arst_i) begin
            if (w_arst_i)
               regfile[i] <= {DATA_W{1'd0}};
            else if (w_en_i && (w_addr_i == i))
               regfile[i] <= w_data_i;
      end
   endgenerate

   //read
   always @(posedge r_clk_i, posedge r_arst_i) begin
      if (r_arst_i)
         r_data_o <= {DATA_W{1'd0}};
      else if (r_en_i)
         r_data_o <= regfile[r_addr_i];
   end
   
endmodule

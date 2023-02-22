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
    input              w_cke_i,
    input [ADDR_W-1:0] w_addr_i,
    input [DATA_W-1:0] w_data_i,

    // Read Port
    input               r_clk_i,
    input               r_arst_i,
    input               r_cke_i,
    input [ADDR_W-1:0]  r_addr_i,
    output reg [DATA_W-1:0] r_data_o
    );

   //write
   `IOB_VAR(regfile_in, ((2**ADDR_W)*DATA_W))
   `IOB_VAR(regfile_synced, ((2**ADDR_W)*DATA_W))

   //write
   genvar i;
   generate
      for(i = 0; i < (2**ADDR_W); i = i + 1) begin: register_file
         always @(posedge w_clk_i, posedge w_arst_i) begin
            if (w_arst_i)
              regfile_in[i*DATA_W+:DATA_W] <= {DATA_W{1'd0}};
            else if (w_cke_i)
              if (w_addr_i == i)
                regfile_in[i*DATA_W+:DATA_W] <= w_data_i;
         end
      end
   endgenerate


   //sync 
   iob_sync
     #(
       .DATA_W((2**ADDR_W)*DATA_W)
       )
   iob_sync_regfile_synced
     (
      .clk_i(r_clk_i),
      .arst_i(r_arst_i),
      .signal_i(regfile_in),
      .signal_o(regfile_synced)
      );
   
   //read
   always @(posedge r_clk_i, posedge r_arst_i) begin
      if (r_arst_i)
         r_data_o <= {DATA_W{1'd0}};
      else if (r_cke_i)
         r_data_o <= regfile_synced[r_addr_i*DATA_W+:DATA_W];
   end
   
endmodule

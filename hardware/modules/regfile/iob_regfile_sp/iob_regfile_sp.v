`timescale 1 ns / 1 ps

module iob_regfile_sp #(
   parameter ADDR_W = 2,
   parameter DATA_W = 21
) (
   input               clk_i,
   input               cke_i,
   input               arst_i,
   input               rst_i,

   input               we_i,
   input [ADDR_W-1:0]  addr_i,
   input [DATA_W-1:0]  d_i,
   output [DATA_W-1:0] d_o
);

   wire [DATA_W*(2**ADDR_W)-1:0] data_in = d_i << (addr_i * DATA_W);
   wire [DATA_W*(2**ADDR_W)-1:0] data_out;
   assign d_o = data_out >> (addr_i * DATA_W);
   
   genvar                        i;
   generate
      for (i = 0; i < 2**ADDR_W; i = i + 1) begin: g_regfile        
         iob_reg_re
               #(
                 .DATA_W(DATA_W)
                 ) regfile_sp_inst 
               (
                .clk_i(clk_i),
                .cke_i(cke_i),
                .arst_i(arst_i),
                .rst_i(rst_i),
                .en_i(we_i),
                .data_i(data_in[DATA_W*(i+1)-1:DATA_W*i]),
                .data_o(data_out[DATA_W*(i+1)-1:DATA_W*i])
                );
      end
   endgenerate
   
endmodule

`timescale 1ns / 1ps

module iob_modcnt_n
  #(
    parameter DATA_W = 32,
    parameter RST_VAL = 0
    )
   (

    input               clk_i,
    input               arst_i,
    input               en_i,

    input               rst_i,
    input               sen_i,

    input [DATA_W-1:0]  mod_i,
    output [DATA_W-1:0] data_o
    );

   wire                 ld = (data_o == mod_i);
   localparam [DATA_W-1:0] LD_VAL = 0;
   
   iob_counter_ld_n #(DATA_W, RST_VAL) cnt0 
     (
      .clk_i(clk_i), 
      .arst_i(arst_i), 
      .en_i(en_i),

      .sen_i(sen_i), 
      .rst_i(rst_i), 

      .ld_i(ld),
      .ld_val_i(LD_VAL), 

      .data_o(data_o)
      );
   
     
endmodule

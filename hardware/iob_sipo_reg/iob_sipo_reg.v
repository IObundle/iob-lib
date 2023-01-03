`timescale 1ns / 1ps

module iob_sipo_reg
  #(
    parameter DATA_W = 32
    )
   (

    input               clk_i,
    input               arst_i,
    input               en_i,

    //serial input
    input               s_i,

    //parallel output
    output [DATA_W-1:0] p_o
    );

   reg [DATA_W-1:0]  data_reg;
   
   always @(posedge clk_i, posedge arst_i)
     if (arst_i)
       data_reg <= {DATA_W{1'b0}};
     else if (en_i)
       data_reg <= (data_reg << 1) | {{(DATA_W-1){1'b0}}, s_i};

   assign p_o = data_reg;
   
endmodule

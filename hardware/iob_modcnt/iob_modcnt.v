`timescale 1ns / 1ps

module iob_modcnt
  #(
    parameter DATA_W = 32
    )
   (

    input                   clk_i,
    input                   arst_i,
    input                   rst_i,
    input                   en_i,

    input [DATA_W-1:0]      ld_val_i,

    input [DATA_W-1:0]      mod_i,

    output reg [DATA_W-1:0] cnt_o
    );

   reg                      loaded;
   
   always @(posedge clk_i, posedge arst_i) 
      if (arst_i) begin
         cnt_o <= -1'b1;
         loaded <= 1'b0;
      end else if (rst_i) begin 
         cnt_o <= -1'b1;
         loaded <= 1'b0;
      end else if (!loaded) begin
          cnt_o <= ld_val_i;
          loaded <= 1'b1;
      end else if (en_i)
        if (cnt_o == (mod_i-1'b1))
          cnt_o <= 1'b0;
        else
          cnt_o <= cnt_o + 1'b1;
   
endmodule

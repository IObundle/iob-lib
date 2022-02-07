`timescale 1ns / 1ps
`include "iob_lib.vh"


module iob_modcnt
  #(
    parameter DATA_W = 32
    )
   (

    input                   clk,
    input                   rst,
    input                   en,

    input [DATA_W-1:0]      ld_val,

    //masters interface
    input [DATA_W-1:0]      mod,

    //slave interface
    output reg [DATA_W-1:0] cnt
    );

   always @(posedge clk, posedge rst)
     if(rst)
       cnt <= 1'b0;
     else if (en)
       if(cnt == (mod-1'b1))
         cnt <= 1'b0;
       else 
         cnt <= cnt + 1'b1;
     else
       cnt <= ld_val;

endmodule

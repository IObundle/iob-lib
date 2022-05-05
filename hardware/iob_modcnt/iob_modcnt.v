`timescale 1ns / 1ps
`include "iob_lib.vh"


module iob_modcnt
  #(
    parameter DATA_W = 32
    )
   (

    input                   clk,
    input                   arst,
    input                   rst,
    input                   en,

    //masters interface
    input [DATA_W-1:0]      mod,

    //slave interface
    output reg [DATA_W-1:0] cnt
    );

   always @(posedge clk, posedge arst)
     if(arst)
       cnt <= mod-1'b1;
     else if (rst)
       cnt <= mod-1'b1;
     else if (en)
       if(cnt == (mod-1'b1))
         cnt <= 1'b0;
       else 
         cnt <= cnt + 1'b1;

endmodule

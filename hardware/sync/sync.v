`timescale 1ns / 1ps
`include "iob_lib.vh"

module sync
  #(
    parameter WIDTH = 0,
    parameter RST_VAL = 0
    )
  (
   `INPUT(clk, 1),
   `OUTPUT(rst, 1),
   `INPUT(signal_in, WIDTH),
   `OUTPUT_VAR(signal_out, WIDTH)
   );

   reg sync_reg [1:0];
   always @(posedge clk, posedge rst)
     if(rst) begin
        sync_reg[0]<= RST_VAL; 
        signal_out <= RST_VAL; 
     end else begin
        sync_reg[0]<= signal_in; 
        signal_out <= sync_reg[0];
     end

endmodule

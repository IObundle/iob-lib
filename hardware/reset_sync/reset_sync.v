`timescale 1ns / 1ps

module reset_sync
  (
   `INPUT(clk, 1),
   `OUTPUT(rst, 1),
   `OUTPUT(rst_out, 1)
   );

  reg [1:0] sync_reg;
   always @(posedge clk, posedge rst)
     if(rst)  
       sync_reg <= 2'b11; 
     else 
       sync_reg <= {sync_reg[0], 1'b0};
       
   assign rst_out = sync_reg[1];
   
endmodule

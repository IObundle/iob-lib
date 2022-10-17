`timescale 1ns/1ps

module iob_gray_counter 
  #(
    parameter   W = 1
    )
   (
    input          clk_i,
    input          rst_i,
    input          en_i,
    output [W-1:0] data_o
    );
   
   reg [W-1:0]     bin_counter;
   reg [W-1:0]     gray_counter;

   assign data_o = gray_counter;
       
   always @ (posedge clk_i, posedge rst_i)
     if (rst_i) begin
        bin_counter  <= 1;
        gray_counter <= 0; 
     end else if (en_i) begin
        bin_counter  <= bin_counter + 1'b1;
        gray_counter <= W > 1? {bin_counter[W-1], bin_counter[W-2:0] ^ bin_counter[W-1:1]} : bin_counter;
     end
   
endmodule

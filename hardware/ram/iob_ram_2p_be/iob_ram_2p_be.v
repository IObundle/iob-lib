`timescale 1ns/1ps

module iob_ram_2p_be
  #( 
     parameter HEXFILE = "none",
     parameter DATA_W = 0,
     parameter ADDR_W = 0
     ) 
   (
    input                   clk,

    //write port
    input [DATA_W/8-1:0]    w_en,
    input [ADDR_W-1:0]      w_addr,
    input [DATA_W-1:0]      w_data,

    //read port
    input                   r_en,
    input [ADDR_W-1:0]      r_addr,
    output reg [DATA_W-1:0] r_data
    );

   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0]         mem [(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial
     if(mem_init_file_int != "none")
       $readmemh(mem_init_file_int, mem, 0, (2**ADDR_W) - 1);

   //read port
   always @(posedge clk)
      if(r_en)
        r_data <= mem[r_addr];

   //write port
   genvar c;
   generate
      for (c = 0; c < DATA_W/8; c = c + 1) begin
         always @(posedge clk)
           if(w_en[c])
             mem[w_addr][c+:8] <= w_data[c+:8];
      end
   endgenerate

endmodule   

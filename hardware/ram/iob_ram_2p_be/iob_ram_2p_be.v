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

   // Wires for internal manipulation of byte enable
   wire [DATA_W-1:0] w_data_int;
   wire [DATA_W-1:0] mem_output = mem[w_addr];
   // Mux to keep current value or get new one based on byte enable
   genvar c;
   generate
      for (c = 0; c < DATA_W/8; c = c + 1) begin
         assign w_data_int[c*8+:8] = w_en[c] ? w_data[c*8+:8] : mem_output[c*8+:8];
      end
   endgenerate

   //write port
   always @(posedge clk)
     if(|w_en)
       mem[w_addr] <= w_data_int;

endmodule   

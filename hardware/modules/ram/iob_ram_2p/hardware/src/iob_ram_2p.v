`timescale 1ns / 1ps

module iob_ram_2p #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 0,
   parameter ADDR_W  = 0
) (
   input clk_i,

   //write port
   input              w_en_i,
   input [ADDR_W-1:0] w_addr_i,
   input [DATA_W-1:0] w_data_i,

   //read port
   input               r_en_i,
   input  [ADDR_W-1:0] r_addr_i,
   output [DATA_W-1:0] r_data_o
);

   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0] mem    [2**ADDR_W];

   reg [DATA_W-1:0] r_data;
   // Initialize the RAM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, mem, 0, (2 ** ADDR_W) - 1);

   //read port
   always @(posedge clk_i) if (r_en_i) r_data <= mem[r_addr_i];

   //write port
   always @(posedge clk_i) if (w_en_i) mem[w_addr_i] <= w_data_i;

   assign r_data_o = r_data;

endmodule

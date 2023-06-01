`timescale 1ns / 1ps

module iob_ram_t2p #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 0,
   parameter ADDR_W  = 0
) (
   // Write port
   input              w_clk_i,
   input              w_en_i,
   input [ADDR_W-1:0] w_addr_i,
   input [DATA_W-1:0] w_data_i,

   // Read port
   input                   r_clk_i,
   input                   r_en_i,
   input      [ADDR_W-1:0] r_addr_i,
   output reg [DATA_W-1:0] r_data_o
);

   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0] ram[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, ram, 0, (2 ** ADDR_W) - 1);

   //write
   always @(posedge w_clk_i) begin
      if (w_en_i) ram[w_addr_i] <= w_data_i;
   end

   //read
   always @(posedge r_clk_i) begin
      if (r_en_i) r_data_o <= ram[r_addr_i];
   end

endmodule

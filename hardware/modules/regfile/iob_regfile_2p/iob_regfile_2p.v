`timescale 1 ns / 1 ps

module iob_regfile_2p
  #(
    parameter ADDR_W = 3,
    parameter DATA_W = 21,
    parameter ADDR_W_INT = (ADDR_W>0)? ADDR_W: 1
  )
  (
    input                     clk_i,
    input                     cke_i,
    
    // Write Port
    input                     wen_i,
    input [ADDR_W_INT-1:0]    waddr_i,
    input [DATA_W-1:0]        wdata_i,

    // Read Port
    input [ADDR_W_INT-1:0]    raddr_i,
    output [DATA_W-1:0]       rdata_o
  );

  reg [DATA_W-1:0] regfile [(2**ADDR_W)-1:0];

  always @(posedge clk_i)
    if (cke_i && wen_i)
      regfile[addr] <= wdata_i;

  assign rdata_o = regfile[raddr_i];
  
endmodule

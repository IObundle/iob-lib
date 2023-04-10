`timescale 1 ns / 1 ps

module iob_regfile_2p
  #(
    parameter ADDR_W = 3,
    parameter DATA_W = 21,
    parameter ADDR_W_INT = (ADDR_W>0)? ADDR_W: 1
  )
  (
    input                     clk_i,
    input                     arst_i,
    input                     cke_i,
    
    // Write Port
    input                     wen_i,
    input [ADDR_W_INT-1:0]    waddr_i,
    input [DATA_W-1:0]        wdata_i,

    // Read Port
    input                     ren_i,
    input [ADDR_W_INT-1:0]    raddr_i,
    output [DATA_W-1:0]       rdata_o
  );

  wire [((2**ADDR_W)*DATA_W)-1 :0] regfile;
  
  genvar addr;
  generate
    for (addr=0; addr < (2**ADDR_W); addr=addr+1) begin: rf
      always @(posedge clk_i)
        if (rst_i)
          regfile[addr] <= {DATA_W{1'b0}};
        else if (wen_i && (addr == addr_i))
          regfile[addr] <= wdata_i;
    end
  endgenerate

  wire [ADDR_W_INT-1:0] raddr = (ren_i == 1'd0) ? raddr_i : {ADDR_W_INT{1'b0}};
  
  assign rdata_o = regfile[(raddr*DATA_W)+:DATA_W];
  
endmodule

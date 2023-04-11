`timescale 1 ns / 1 ps

module iob_regfile_2p_readpar
  #(
    parameter WADDR_W = 3,
    parameter WDATA_W = 21,
    parameter RDATA_W = 21,
    parameter R = WDATA_W/RDATA_W,
    parameter WADDR_W_INT = (WADDR_W>0)? WADDR_W: 1
  )
  (
    input                              clk_i,
    input                              arst_i,
    input                              cke_i,

    // Write Port
    input [R-1:0]                      wstrb_i,
    input [WADDR_W_INT-1:0]            waddr_i,
    input [WDATA_W-1:0]                wdata_i,

    // Read Port
    output [((2**WADDR_W)*WDATA_W)-1 :0] rdata_o
  );

  wire [(R*(2**WADDR_W))-1:0]             wstrb;
  
  genvar                               col, row;
  generate
    for (col=0; col < (2**WADDR_W); col=col+1) begin: rf
      for (row=0; row < R; row=row+1) begin: rf_row
        assign wstrb[(col*R)+row] = (waddr_i == col) & wstrb_i[row];
        iob_reg_e #(
          RDATA_W, 
          {{(RDATA_W-1){1'd0}}, 1'd1}
        ) iob_reg_rf_row_slice (
          .clk_i (clk_i),
          .arst_i (arst_i),
          .cke_i (cke_i),
          .en_i (wstrb[(col*R)+row]),
          .data_i (wdata_i[row*RDATA_W +: RDATA_W]),
          .data_o (rdata_o[(col*WDATA_W)+(row*RDATA_W) +: RDATA_W])
        );
      end
    end
  endgenerate
  
endmodule

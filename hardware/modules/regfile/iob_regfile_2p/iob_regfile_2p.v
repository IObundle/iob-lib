`timescale 1 ns / 1 ps
`include "iob_utils.vh"

module iob_regfile_2p 
  #(
    parameter N = 0, //number of registers
    parameter W = 0, //register width
    parameter WDATA_W = 0, //width of write data
    parameter WADDR_W = 0, //width of write address
    parameter RDATA_W = 0, //width of read data
    parameter RADDR_W = 0, //width of read address
    //cpu interface
    parameter DATA_W = 0, //width of data
    parameter WSTRB_W = WDATA_W/8 //width of write strobe
    ) 
(
 input                                       clk_i,
 input                                       arst_i,
 input                                       cke_i,
 input                                       wen_i,
 input [RADDR_W+WADDR_W+WSTRB_W+WDATA_W-1:0] req_i,
 output [RDATA_W-1:0]                        resp_o
 );

   //register file and register file write enable
   wire [(N*W)-1 : 0]                        regfile;
   wire [N-1:0]                               wen;

   //reconstruct write address from waddr_i and wstrb_i
   wire [WSTRB_W-1:0]                        wstrb  = req_i[WDATA_W+:WSTRB_W];
   wire [WADDR_W-1:0]                        waddr = req_i[WSTRB_W+WDATA_W+:WADDR_W];
   wire [WADDR_W-1:0]                        waddr_int;
   wire [$clog2(DATA_W/8):0]                 waddr_incr;

   iob_ctls #(
       .N     (DATA_W / 8),
       .MODE  (0),
       .SYMBOL(0)
   ) iob_ctls_txinst (
      .data_i (wstrb),
      .count_o(waddr_incr)
   );
   assign waddr_int = waddr + waddr_incr;

   //write register file
   localparam WDATA_INT_W = WSTRB_W*W;
   wire [WDATA_W-1:0] wdata_int = req_i[WDATA_W-1:0];
   genvar                                    i;
   genvar                                    j;

   localparam IEND = N/WSTRB_W + (N%WSTRB_W ? 1 : 0);
   generate
      for (i = 0; i < IEND; i = i + 1) begin : g_rows
         for (j = 0; j < WSTRB_W; j = j + 1) begin : g_columns

            if ( (i*WSTRB_W+j) < N ) begin: g_if
               assign wen[i*WSTRB_W+j] = wen_i & (waddr_int == (i*WSTRB_W+j));
               iob_reg_e 
                 #(
                   .DATA_W (W),
                   .RST_VAL({W{1'b0}}),
                   .CLKEDGE("posedge")
                   ) 
               iob_reg_inst 
                 (
                  .clk_i (clk_i),
                  .arst_i(arst_i),
                  .cke_i (cke_i),
                  .en_i  (wen[(i*WSTRB_W)+j]),
                  .data_i(wdata_int[(i*8)+(j*W) +: W]),
                  .data_o(regfile[(i*WDATA_INT_W)+(j*W) +: W])
                  );
            end
         end
      end
   endgenerate

   //read register file
   generate 
      if (RADDR_W > 0) begin : g_read
         assign resp_o = regfile[req_i[WSTRB_W+WDATA_W+WADDR_W+:RADDR_W]+: RDATA_W];
      end 
   endgenerate

endmodule

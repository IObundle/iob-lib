`timescale 1 ns / 1 ps
`include "iob_utils.vh"

`define IOB_REGFILE_RADDR(req_i) (req_i[WADDR_W+WSTRB_W+WDATA_W+:RADDR_W])
`define IOB_REGFILE_WADDR(req_i) (req_i[WSTRB_W+WDATA_W+:WADDR_W])
`define IOB_REGFILE_WSTRB(req_i) (req_i[WDATA_W+:WSTRB_W])
`define IOB_REGFILE_WDATA(req_i) (req_i[WDATA_W-1:0])

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
 output [RDATA_W-1:0]                        resp_i
 );

   //register file
   reg [W-1 : 0]                             regfile [N-1:0];
   //register file write enable
   reg [N-1:0]                               wen;



   
   //reconstruct write address from waddr_i and wstrb_i
   wire                                      wstrb [WSTRB_W-1:0] = req_i[WDATA_W+:WSTRB_W];
   wire [WADDR_W-1:0]                        waddr_int;
   wire [$clog2(DATA_W/8):0]                 waddr_incr;
   iob_ctls #(
       .N     (DATA_W / 8),
       .MODE  (0),
       .SYMBOL(0)
   ) iob_ctls_txinst (
      .data_i (wstrb_i),
      .count_o(waddr_incr)
   );
   assign waddr_int = waddr_i + waddr_incr;

   //reconstruct write data 
   wire [WSTRB_W-1:0]                        wdata = req_i[WDATA_W-1:0];
   reg [WSTRB_W-1:0]                         wdata;
   integer                                   k;
   always_comb begin
      wdata_int = {WSTRB_W{1'b0}};
      for (k = 0; k < (DATA_W / 8); k = k + 1)
        if (k == waddr_incr) wdata_int = wdata[8*k +: W];
   end


   //write register file
   genvar                                    i;
   genvar                                    j;
   generate
      for (i = 0; i < N; i = i + WSTRB_W) begin : g_i
         for (j = 0; j < WSTRB_W; j = j + 1) begin : g_j

            if ( (i*WSTRB_W+j) < N ) begin: g_if
               assign wen[i*WSTRB_W+j] = wen_i & (waddR_int == (i*WSTRB_W+j));
               iob_reg_e 
                 #(
                   .DATA_W (DATA_W),
                   .RST_VAL({DATA_W{1'b0}}),
                   .CLKEDGE("posedge")
                   ) 
               iob_reg_inst 
                 (
                  .clk_i (clk_i),
                  .arst_i(arst_i),
                  .cke_i (cke_i),
                  .en_i  (wen[i*WSTRB_W+j]),
                  .data_i(wdata_int),
                  .data_o(regfile[i*WSTRB_W+j])
                  );
            end
         end
      end
   endgenerate

   //read register file
   assign rdata_o = regfile[raddr_i +: RDATA_W];

endmodule

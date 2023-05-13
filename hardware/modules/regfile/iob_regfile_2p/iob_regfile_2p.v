`timescale 1 ns / 1 ps


module iob_regfile_2p #(
    parameter W_DATA_W = 21,
    parameter R_DATA_W = 21,
    parameter ADDR_W = 21,  //address width for lower DATA_W
    //determine W_ADDR_W and R_ADDR_W
    parameter MAXDATA_W =
    `IOB_MAX(W_DATA_W, R_DATA_W),
    parameter MINDATA_W =
    `IOB_MIN(W_DATA_W, R_DATA_W),
    parameter R = MAXDATA_W / MINDATA_W,
    parameter MAXADDR_W = ADDR_W + $clog2(R),  //address width for higher DATA_W
    parameter W_ADDR_W = (W_DATA_W == MAXDATA_W) ? ADDR_W : MAXADDR_W,
    parameter R_ADDR_W = (R_DATA_W == MAXDATA_W) ? ADDR_W : MAXADDR_W,
    parameter WSTRB_W = (W_DATA_W == MAXDATA_W) ? R : 1
) (
    input clk_i,
    input arst_i,
    input cke_i,

    // Write Port
    input [ WSTRB_W-1:0] wstrb_i,
    input [W_ADDR_W-1:0] waddr_i,
    input [W_DATA_W-1:0] wdata_i,

    // Read Port
    input  [R_ADDR_W-1:0] raddr_i,
    output [R_DATA_W-1:0] rdata_o
);

   reg [MINDATA_W-1:0] regfile[0:(2**MAXADDR_W)-1];

   genvar addr;
   //Generate the memory based on the parameters
   generate
      if (W_DATA_W >= R_DATA_W) begin : g_wdata_ge_rdata
         localparam R_LOG2 = $clog2(R);
         //Write
         for (addr = 0; addr < (2 ** MAXADDR_W); addr = addr + 1) begin : rf_addr
            wire addr_wen;
            assign addr_wen = ((addr >> R_LOG2) == waddr_i) && wstrb_i[addr[0+:R_LOG2]];
            always @(posedge clk_i, posedge arst_i)
               if (arst_i) regfile[addr] <= {MINDATA_W{1'd0}};
               else if (cke_i && addr_wen)
                  regfile[addr] <= wdata_i[addr[0+:R_LOG2]*MINDATA_W+:MINDATA_W];
         end

         //Read
         assign rdata_o = regfile[raddr_i];
      end else begin : g_wdata_l_rsda //W_DATA_W < R_DATA_W
         //Write
         for (addr = 0; addr < (2 ** MAXADDR_W); addr = addr + 1) begin : rf_addr
            wire addr_wen;
            assign addr_wen = (addr == waddr_i) && wstrb_i;
            always @(posedge clk_i, posedge arst_i)
               if (arst_i) regfile[addr] <= {MINDATA_W{1'd0}};
               else if (cke_i && addr_wen) regfile[addr] <= wdata_i;

            //Read
            genvar slice;
            for (slice = 0; slice < R; slice = slice + 1) begin : rf_slice
               assign rdata_o[slice*MINDATA_W+:MINDATA_W] = regfile[(raddr_i*R)+slice];
            end
         end
      end
   endgenerate

endmodule

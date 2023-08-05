`timescale 1ns / 1ps

module iob_div_subshift #(
   parameter DATA_W = 32
) (
   `include "clk_en_rst_s_port.vs"

   input      start_i,
   output reg done_o,

   input  [DATA_W-1:0] dividend_i,
   input  [DATA_W-1:0] divisor_i,
   output [DATA_W-1:0] quotient_o,
   output [DATA_W-1:0] remainder_o
);

   //dividend/quotient/remainder register
   reg  [2*DATA_W:0] dqr_nxt;
   wire [2*DATA_W:0] dqr_reg;

   iob_reg #(
      .DATA_W (2 * DATA_W + 1),
      .RST_VAL(1'b0)
   ) dqr_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"

      .data_i(dqr_nxt),
      .data_o(dqr_reg)
   );

   //divisor register
   reg  [DATA_W-1:0] divisor_nxt;
   wire [DATA_W-1:0] divisor_reg;

   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL(1'b0)
   ) div_reg0 (
      `include "clk_en_rst_s_s_portmap.vs"

      .data_i(divisor_nxt),
      .data_o(divisor_reg)
   );

   wire [DATA_W-1:0] subtraend = dqr_reg[2*DATA_W-2-:DATA_W];
   reg  [  DATA_W:0] tmp;

   //output quotient and remainder
   assign quotient_o  = dqr_reg[DATA_W-1:0];
   assign remainder_o = dqr_reg[2*DATA_W-1:DATA_W];


   //
   //PROGRAM
   //

   reg [$clog2(DATA_W+2):0] pc, pc_nxt;  //program counter
   always @(posedge clk_i, posedge arst_i)
      if (arst_i) pc <= 1'b0;
      else pc <= pc_nxt;

   always @* begin
      pc_nxt      = pc + 1'b1;
      dqr_nxt     = dqr_reg;
      divisor_nxt = divisor_reg;
      done_o      = 1'b1;

      case (pc)
         0: begin  //wait for start, load operands and do it
            if (!start_i) begin
               pc_nxt = pc;
            end else begin
               divisor_nxt = divisor_i;
               dqr_nxt     = {{DATA_W{1'b0}}, dividend_i};
            end
         end

         DATA_W + 1: begin
            pc_nxt = 1'b0;
         end

         default: begin  //shift and subtract
            done_o = 1'b0;
            tmp    = {1'b0, subtraend} - {1'b0, divisor_reg};
            if (~tmp[DATA_W]) dqr_nxt = {tmp, dqr_reg[DATA_W-2 : 0], 1'b1};
            else dqr_nxt = {dqr_reg[2*DATA_W-2 : 0], 1'b0};
         end
      endcase  // case (pc)
   end

endmodule

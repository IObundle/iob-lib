`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_merge #(
   parameter N_MASTERS = 2,
   parameter DATA_W    = 32,
   parameter ADDR_W    = 32
) (
   input clk_i,
   input arst_i,

   //masters interface
   input      [ N_MASTERS*`REQ_W-1:0] m_req_i,
   output reg [N_MASTERS*`RESP_W-1:0] m_resp_o,

   //slave interface
   output reg [ `REQ_W-1:0] s_req_o,
   input      [`RESP_W-1:0] s_resp_i
);


   localparam Nb = $clog2(N_MASTERS) + ($clog2(N_MASTERS) == 0);

   wire s_ready;
   wire m_avalid [N_MASTERS];
   reg  [Nb-1:0] sel;
   wire [Nb-1:0] sel_q;

   assign s_ready  = s_resp_i[`READY(0)];

   //select master
   generate
      genvar c;
      for (c = 0; c < N_MASTERS; c = c + 1) begin : g_m_avalids
         assign m_avalid[c] = m_req_i[`AVALID(c)];
      end
   endgenerate

   //
   //priority encoder: most significant bus has priority
   //
   integer k;
   always @* begin
      if (s_ready) begin
         sel = {Nb{1'b0}};
         for (k = 0; k < N_MASTERS; k = k + 1) begin
            if (m_avalid[k]) sel = k[Nb-1:0];
         end
      end else begin
         sel = sel_q;
      end
   end

   //
   //route master request to slave
   //
   assign s_req_o = m_req_i[`REQ(sel)];

   //
   //route response from slave to previously selected master
   //
   integer j;
   always @* begin
      for (j = 0; j < N_MASTERS; j = j + 1) begin
         if (j == sel_q) begin
            m_resp_o[`RDATA(j)] = s_resp_i[`RDATA(0)];
            m_resp_o[`RVALID(j)] = s_resp_i[`RVALID(0)];
         end else begin
            m_resp_o[`RDATA(j)] = {DATA_W{1'b0}};
            m_resp_o[`RVALID(j)] = 1'b0;
         end
         if (j == sel) begin
             m_resp_o[`READY(j)] = s_resp_i[`READY(0)];
         end else begin
            m_resp_o[`READY(j)] = 1'b0;
         end
      end
   end

   //register master selection
   iob_reg_re #(
      .DATA_W (Nb),
      .RST_VAL(0)
   ) iob_reg_sel (
      `include "clk_rst_s_s_portmap.vs"
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(sel),
      .data_o(sel_q)
   );

endmodule

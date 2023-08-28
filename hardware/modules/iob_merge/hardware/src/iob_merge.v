`timescale 1ns / 1ps

`include "iob_utils.vh"

// Merge the IOb native interface, from multiple masters to a single follower
module iob_merge #(
   parameter ADDR_W = 32,
   parameter DATA_W = 32,
   parameter N      = 2,             // Number of masters, minimum of 2
   parameter NB     = $clog2(N)      // Number of bits needed to address all masters
) (
   `include "clk_rst_s_port.vs"

   // Masters' interface
   input  [N*1-1:0]      m_avalid_i,
   input  [ADDR_W-1:0]   m_address_i,
   input  [DATA_W-1:0]   m_wdata_i,
   input  [4-1:0]        m_wstrb_i,
   output [N*DATA_W-1:0] m_rdata_o,
   output [N*1-1:0]      m_rvalid_o,
   output [N*1-1:0]      m_ready_o,

   // Follower's interface
   output                f_avalid_o,
   output [ADDR_W-1:0]   f_address_o,
   output [DATA_W:0]     f_wdata_o,
   output [4-1:0]        f_wstrb_o,
   input  [DATA_W:0]     f_rdata_i,
   input                 f_rvalid_i,
   input                 f_ready_i,

   // Master selection source (an array of bits, where each bit represents a master and
   // is set to 1 if that one master is selected)
   input  [N-1:0]       m_sel_src_i
);

   //
   // Select the master and register the selection
   //

   wire [NB-1:0] m_sel;
   integer k;
   always @* begin
      for (k = 0; k < N; k = k + 1) begin
         if (m_sel_src_i[k]) begin
            m_sel = k[NB-1:0];
         end
      end
   end

   wire [NB-1:0] m_sel_r;
   iob_reg_re #(
      .DATA_W (NB),
      .RST_VAL(0)
   ) reg_m_sel (
      `include "clk_rst_s_s_portmap.vs"
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (m_avalid_o),
      .data_i(m_sel),
      .data_o(m_sel_r)
   );

   //
   // Route selected master request to follower
   //

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(m_avalid_i),
      .data_o(f_avalid_o)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(m_address_i),
      .data_o(f_address_o)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(m_wdata_i),
      .data_o(f_wdata_o)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(m_wstrb_i),
      .data_o(f_wstrb_o)
   );

   //
   // Route selected master response to follower
   //

   iob_demux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(f_rdata_i),
      .data_o(m_rdata_o)
   );

   iob_demux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(f_rvalid_i),
      .data_o(m_rvalid_o)
   );

   iob_demux #(
      .DATA_W (1),
      .N      (N)
   ) mux_avalid (
      .sel_i (m_sel_r),
      .data_i(f_ready_i),
      .data_o(m_ready_o)
   );

endmodule

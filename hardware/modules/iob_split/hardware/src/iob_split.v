`timescale 1ns / 1ps

`include "iob_utils.vh"

// Split the IOb native interface, from a single master to multiple followers
module iob_split #(
   parameter ADDR_W   = 32,
   parameter DATA_W   = 32,
   parameter N = 2,              // Number of followers, minimum of 2
   parameter NB = $clog2(N)      // Number of bits needed to address all followers
) (
   `include "clk_rst_s_port.vs"

   // Master's interface
   output              m_avalid,
   output [ADDR_W-1:0] m_address,
   output [DATA_W:0]   m_wdata,
   output [4-1:0]      m_wstrb,
   input  [DATA_W:0]   m_rdata,
   input               m_rvalid,
   input               m_ready,

   // Followers' interface
   output [N*1-1:0]      f_avalid,
   output [ADDR_W-1:0]   f_address,
   output [DATA_W-1:0]   f_wdata,
   output [4-1:0]        f_wstrb,
   input  [N*DATA_W-1:0] f_rdata,
   input  [N*1-1:0]      f_rvalid,
   input  [N*1-1:0]      f_ready,

   input  [NB-1:0] f_sel
);

   //
   // Register the follower selection
   //

   wire [NB-1:0] f_sel_r;
   iob_reg_re #(
      .DATA_W (NB),
      .RST_VAL(0)
   ) iob_reg_f_sel (
      `include "clk_rst_s_s_portmap.vs"
      .cke_i (1'b1),
      .rst_i (1'b0),
      .en_i  (m_avalid),
      .data_i(f_sel),
      .data_o(f_sel_r)
   );

   //
   // Route master request to selected follower
   //

   // Avalid goes to the selected follower
   iob_demux #(
      .DATA_W (1),
      .N      (N)
   ) demux_avalid (
      .sel_i (f_sel_r),
      .data_i(m_avalid),
      .data_o(f_avalid)
   );

   // These go to all followers (only the one with asserted avalid will use them)
   assign f_address = m_address;
   assign f_wdata   = m_wdata;
   assign f_wstrb   = m_wstrb;

   //
   // Route selected follower response to master
   //

   iob_mux #(
      .DATA_W (DATA_W),
      .N      (N)
   ) mux_rdata (
      .sel_i (f_sel_r),
      .data_i(f_rdata),
      .data_o(m_rdata)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_rvalid (
      .sel_i (f_sel_r),
      .data_i(f_rvalid),
      .data_o(m_rvalid)
   );

   iob_mux #(
      .DATA_W (1),
      .N      (N)
   ) mux_ready (
      .sel_i (f_sel_r),
      .data_i(f_ready),
      .data_o(m_ready)
   );

endmodule

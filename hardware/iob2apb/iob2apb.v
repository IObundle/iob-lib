`timescale 1ns / 1ps

`include "iob_lib.vh"

module iob2apb
  #(
    parameter APB_ADDR_W = 32,     // APB address bus width in bits
    parameter APB_DATA_W = 32,     // APB data bus width in bits
    parameter ADDR_W = APB_ADDR_W, // IOb address bus width in bits
    parameter DATA_W = APB_DATA_W  // IOb data bus width in bits
    )
   (
    // APB master interface
`include "apb_m_port.vh"

    // IOb slave interface
`include "iob_s_port.vh"

    // Global signals
`include "iob_clkrst_port.vh"
    );

   //
   // COMPUTE APB OUTPUTS
   //

   // select
   assign apb_sel_o = iob_avalid_i;

   // enable
   assign apb_enable_o = iob_avalid_i;

   // protection
   assign apb_prot_o = 3'd2;

   // address
   assign apb_addr_o = iob_addr_i;

   // write
   assign apb_write_o = |iob_wstrb_i;
   assign apb_wdata_o = iob_wdata_i;
   assign apb_wstrb_o = iob_wstrb_i;

   //
   // COMPUTE IOb OUTPUTS
   //
   assign iob_ready_o  = apb_ready_i;
   assign iob_rvalid_nxt = iob_avalid_i & iob_ready_o;
   assign iob_rdata_o  = apb_rdata_i;

   iob_reg_a #(1,0) iob_avalid_reg0 (clk_i, arst_i, iob_avalid_nxt, iob_rvalid_o);

endmodule

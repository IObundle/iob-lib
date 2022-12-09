`timescale 1ns / 1ps

`include "iob_lib.vh"

module apb2iob
  #(
    parameter APB_ADDR_W = 32,     // APB address bus width in bits
    parameter APB_DATA_W = 32,     // APB data bus width in bits
    parameter ADDR_W = APB_ADDR_W, // IOb address bus width in bits
    parameter DATA_W = APB_DATA_W  // IOb data bus width in bits
    )
   (
    // APB slave interface
`include "apb_s_port.vh"

    // IOb master interface
`include "iob_m_port.vh"

    // Global signals
`include "iob_clkrst_port.vh"
    );

   //
   // COMPUTE APB OUTPUTS
   //

   // ready
   assign apb_ready_o = iob_ready_i;

   // write response
   assign apb_slverr_o = 1'b0;

   // read
   assign apb_rdata_o = iob_rdata_i;

   //
   // COMPUTE IOb OUTPUTS
   //
   assign iob_avalid_o = apb_sel_i;
   assign iob_addr_o  = apb_addr_i;
   assign iob_wdata_o = apb_wdata_i;
   assign iob_wstrb_o = apb_wstrb_i;

endmodule

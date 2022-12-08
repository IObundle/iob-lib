`timescale 1ns / 1ps

`include "iob_lib.vh"

module iob2axil
  #(
    parameter ADDR_W = 32, // IOb address bus width in bits
    parameter DATA_W = 32,  // IOb data bus width in bits
    parameter AXIL_ADDR_W = ADDR_W,     // AXI Lite address bus width in bits
    parameter AXIL_DATA_W = DATA_W     // AXI Lite data bus width in bits
   )
   (
    //
    // AXI4 Lite master interface
    //
`include "axil_m_port.vh"

    //
    // IOb slave interface
    //
`include "iob_s_port.vh"

    // Global signals
`include "iob_clkrst_port.vh"
    );

   //
   // COMPUTE IOb OUTPUTS
   //
   assign iob_rvalid_o = axil_rvalid_i;
   assign iob_rdata_o  = axil_rdata_i;
   assign iob_ready_o  = iob_wstrb_i? axil_wready_i : axil_arready_i;

   //
   // COMPUTE AXIL OUTPUTS
   //

   // write address
   assign axil_awvalid_o = iob_avalid_i & |iob_wstrb_i;
   assign axil_awaddr_o  = iob_addr_i;
   assign axil_awprot_o  = 3'd2;

   // write
   assign axil_wvalid_o = iob_avalid_i & |iob_wstrb_i;
   assign axil_wdata_o  = iob_wdata_i;
   assign axil_wstrb_o  = iob_wstrb_i;

   // write response
   assign axil_bready_o = 1'b1;

   // read address
   assign axil_arvalid_o = iob_avalid_i & ~|iob_wstrb_i;
   assign axil_araddr_o  = iob_addr_i;
   assign axil_arprot_o  = 3'd2;

   // read
   assign axil_rready_o = 1'b1;

endmodule

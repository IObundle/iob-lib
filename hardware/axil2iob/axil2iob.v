`timescale 1ns / 1ps

`include "iob_lib.vh"

module axil2iob
  #(
    parameter AXIL_ADDR_W = 32,     // AXI Lite address bus width in bits
    parameter AXIL_DATA_W = 32,     // AXI Lite data bus width in bits
    parameter AXIL_ID_W = 1,        // AXI Lite ID bus width in bits
    parameter ADDR_W = AXIL_ADDR_W, // IOb address bus width in bits
    parameter DATA_W = AXIL_DATA_W  // IOb data bus width in bits
    )
   (
    // AXI-4 lite slave interface
    //START_IO_TABLE axil_s_port
    `IOB_INPUT(axil_awid_i, AXIL_ID_W), //Address write channel ID.
    `IOB_INPUT(axil_awaddr_i, AXIL_ADDR_W), //Address write channel address.
    `IOB_INPUT(axil_awprot_i, 3), //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    `IOB_INPUT(axil_awqos_i, 4), //Address write channel quality of service.
    `IOB_INPUT(axil_awvalid_i, 1), //Address write channel valid.
    `IOB_OUTPUT(axil_awready_o, 1), //Address write channel ready.
    `IOB_INPUT(axil_wdata_i, AXIL_DATA_W), //Write channel data.
    `IOB_INPUT(axil_wstrb_i, (AXIL_DATA_W/8)), //Write channel write strobe.
    `IOB_INPUT(axil_wvalid_i, 1), //Write channel valid.
    `IOB_OUTPUT(axil_wready_o, 1), //Write channel ready.
    `IOB_OUTPUT(axil_bid_o, AXIL_ID_W), //Write response channel ID.
    `IOB_OUTPUT(axil_bresp_o, 2), //Write response channel response.
    `IOB_OUTPUT(axil_bvalid_o, 1), //Write response channel valid.
    `IOB_INPUT(axil_bready_i, 1), //Write response channel ready.
    `IOB_INPUT(axil_arid_i, AXIL_ID_W), //Address read channel ID.
    `IOB_INPUT(axil_araddr_i, AXIL_ADDR_W), //Address read channel address.
    `IOB_INPUT(axil_arprot_i, 3), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
    `IOB_INPUT(axil_arqos_i, 4), //Address read channel quality of service.
    `IOB_INPUT(axil_arvalid_i, 1), //Address read channel valid.
    `IOB_OUTPUT(axil_arready_o, 1), //Address read channel ready.
    `IOB_OUTPUT(axil_rid_o, AXIL_ID_W), //Read channel ID.
    `IOB_OUTPUT(axil_rdata_o, AXIL_DATA_W), //Read channel data.
    `IOB_OUTPUT(axil_rresp_o, 2), //Read channel response.
    `IOB_OUTPUT(axil_rvalid_o, 1), //Read channel valid.
    `IOB_INPUT(axil_rready_i, 1), //Read channel ready.

    // IOb master interface
    //START_IO_TABLE iob_m
    `IOB_OUTPUT(valid_o, 1),        //Request valid.
    `IOB_INPUT(ready_i,  1),        //Interface ready.
    `IOB_OUTPUT(addr_o,  ADDR_W),   //Address.
    `IOB_OUTPUT(wdata_o, DATA_W),   //Write data.
    `IOB_OUTPUT(wstrb_o, DATA_W/8), //Write strobe.
    `IOB_INPUT(rvalid_i, 1),        //Read data valid.
    `IOB_INPUT(rdata_i,  DATA_W),   //Read data.

    // Global signals
    //START_IO_TABLE global
    `IOB_INPUT(clk_i,          1), //System clock input.
    `IOB_INPUT(rst_i,          1)  //System reset, asynchronous and active high.
    );

   //
   // COMPUTE AXIL OUTPUTS
   //
   
   // write address
   assign axil_awready_o = ready_i;

   // write
   assign axil_wready_o = ready_i;

   // write response
   assign axil_bid_o = 1'b0;
   assign axil_bresp_o = 2'b0;
   assign axil_bvalid_o = 1'b1;

   // read address
   assign axil_arready_o = ready_i;

   // read
   assign axil_rid_o = 1'b0;
   assign axil_rdata_o = rdata_i;
   assign axil_rresp_o = 2'b0;
   assign axil_rvalid_o = rvalid_i;

   //
   // COMPUTE IOb OUTPUTS
   //
   assign valid_o = axil_awvalid_i | axil_wvalid_i | axil_arvalid_i;
   assign addr_o  = axil_awvalid_i? axil_awaddr_i: axil_araddr_i;
   assign wdata_o = axil_wdata_i;
   assign wstrb_o = axil_wvalid_i? axil_wstrb_i: {DATA_W/8{1'b0}};

endmodule

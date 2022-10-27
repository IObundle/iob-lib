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
`include "iob_axil_s_port.vh"

    // IOb master interface
`include "iob_m_port.vh"

    // Global signals
`include "iob_clkrst_port.vh"
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
   assign axil_arready_o = axil_arvalid_i & ready_i;

   // read
   assign axil_rid_o = 1'b0;
   assign axil_rdata_o = rdata_i;
   assign axil_rresp_o = 2'b0;
   assign axil_rvalid_o = rvalid_i;

   //
   // COMPUTE IOb OUTPUTS
   //
   `IOB_WIRE(axil_avalid, 1)
   `IOB_WIRE(axil_addr, ADDR_W)
   `IOB_WIRE(axil_addr_reg, ADDR_W)

   assign valid_o = axil_wvalid_i | axil_arvalid_i;
   assign addr_o  = axil_avalid? axil_addr: axil_addr_reg;
   assign wdata_o = axil_wdata_i;
   assign wstrb_o = axil_wvalid_i? axil_wstrb_i: {DATA_W{1'b0}};

   // Address register
   assign axil_avalid = axil_awvalid_i | axil_arvalid_i;
   assign axil_addr   = axil_awvalid_i? axil_awaddr_i: axil_araddr_i;

   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_addr
     (
      .clk_i  (clk_i),
      .arst_i (rst_i),
      .rst_i  (1'b0),
      .en_i   (axil_avalid),
      .data_i (axil_addr),
      .data_o (axil_addr_reg)
      );

endmodule

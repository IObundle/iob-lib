`timescale 1ns / 1ps

`include "iob_lib.vh"

module axil2iob
  #(
    parameter AXIL_ADDR_W = 32, // AXI Lite address bus width in bits
    parameter AXIL_DATA_W = 32, // AXI Lite data bus width in bits
    parameter AXI_ID_W = 1,     // AXI Lite ID bus width in bits
    parameter ADDR_W = AXIL_ADDR_W, // IOb address bus width in bits
    parameter DATA_W = AXIL_DATA_W // IOb data bus width in bits
    )
   (
    // AXI-4 lite slave interface
`include "iob_axil_s_port.vh"

    // IOb master interface
`include "iob_m_port.vh"

    //Global signals
`include "iob_clkrst_port.vh"
    );

   //
   //COMPUTE AXIL OUTPUTS
   //
   
   //write address  
   assign axil_awready_o = ready_i;

   //write 
   assign axil_wready_o = ready_i;

   //write response
   assign axil_bid_o = 1'b0;
   assign axil_bresp_o = 2'b0;
   assign axil_bvalid_o = 1'b1;

   //read address
   assign axil_arready_o = ready_i;

   //read 
   assign axil_rid_o = 1'b0;
   assign axil_rdata_o = rdata_i;
   assign axil_bresp_o = 2'b0;
   assign axil_rvalid_o = rvalid_i;


   //
   //COMPUTE IOb OUTPUTS
   //

   `IOB_WIRE(wvalid_reg, 1)
   assign valid_o = wvalid_reg | axil_arvalid_i;

   `IOB_WIRE(addr_reg, ADDR_W)
   assign addr_o = addr_reg;
 
   `IOB_WIRE(wdata_reg, DATA_W)
   assign wdata_o = wdata_reg;
 
   `IOB_WIRE(wstrb_reg, DATA_W/8)
   assign wstrb_o = wstrb_reg;
 
   //write valid register
   iob_reg #(.DATA_W(1), .RST_VAL(0))
   iob_reg_wvalid
     (
      .clk_i  (clk_i),
      .arst_i (rst_i),
      .rst_i  (1'b0),
      .en_i   (1'b1),
      .data_i (axil_wvalid),
      .data_o (wvalid_reg)
      );

   //address register
   `IOB_WIRE(addr_reg_en, 1)
   assign addr_reg_en = axil_awvalid_i | axil_arvalid_i;

   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_addr
     (
      .clk_i  (clk_i),
      .arst_i (rst_i),
      .rst_i  (1'b0),
      .en_i   (addr_reg_en),
      .data_i (axil_awaddr_i),
      .data_o (addr_reg)
      );

   //wdata register
   iob_reg #(.DATA_W(DATA_W), .RST_VAL(0))
   iob_reg_wdata
     (
      .clk_i  (clk_i),
      .arst_i (rst_i),
      .rst_i  (1'b0),
      .en_i   (axil_wvalid_i),
      .data_i (axil_wdata_i),
      .data_o (wdata_reg)
      );


   //wstrb register
   iob_reg #(.DATA_W(DATA_W/8), .RST_VAL(0))
   iob_reg_wstrb
     (
      .clk_i  (clk_i),
      .arst_i (rst_i),
      .rst_i  (1'b0),
      .en_i   (axil_wvalid_i),
      .data_i (axil_wstrb_i),
      .data_o (wstrb_reg)
      );

endmodule

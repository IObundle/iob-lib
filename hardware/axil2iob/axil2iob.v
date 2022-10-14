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
    `IOB_INPUT(clk, 1),
    `IOB_INPUT(rst, 1)
    );

   //
   //COMPUTE AXIL OUTPUTS
   //
   
   //write address  
   assign axil_awready = ready;

   //write 
   assign axil_wready = ready;

   //write response
   assign axil_bid = 1'b0;
   assign axil_bresp = 2'b0;
   assign axil_bvalid = wvalid;

   //read address
   assign axil_arready = ready;

   //read 
   assign axil_rid = 1'b0;
   assign axil_rdata = rdata;
   assign axil_bresp = 2'b0;
   assign axil_rvalid = rvalid;


   //
   //COMPUTE IOb OUTPUTS
   //

   `IOB_WIRE(wvalid_reg, q)
   assign valid = wvalid_reg | axil_arvalid;

   `IOB_WIRE(addr_reg, ADDR_W)
   assign addr = addr_reg;
 
   `IOB_WIRE(wdata_reg, ADDR_W)
   assign addr = wdata_reg;
 
   `IOB_WIRE(wstrb_reg, DATA_W/8)
   assign wstrb = wstrb_reg;
 
   //write valid register
   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_wvalid
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (1'b1),
      .data_in    (axil_wvalid),
      .data_out   (wvalid_reg)
      );

   //address register
   `IOB_WIRE(addr_reg_en, 1)
   assign addr_reg_en = axil_awvalid | axil_arvalid;

   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_addr
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (addr_reg_en),
      .data_in    (axil_awaddr),
      .data_out   (addr_reg)
      );

   //wdata register
   iob_reg #(.DATA_W(DATA_W), .RST_VAL(0))
   iob_reg_wdata
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (axil_wvalid),
      .data_in    (axil_wdata),
      .data_out   (wdata_reg)
      );


   //wstrb register
   iob_reg #(.DATA_W(DATA_W), .RST_VAL(0))
   iob_reg_wstrb
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (axil_wvalid),
      .data_in    (axil_wstrb),
      .data_out   (wstrb_reg)
      );

endmodule

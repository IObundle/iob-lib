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
`include "iob_gen_if.vh"
    );

   //COMPUTE AXIL OUTPUTS
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

   
   //COMPUTE IOb OUTPUTS

   //valid 
   assign valid = axil_wvalid | axil_rvalid;


   //address

   //axil write address valid register
   `IOB_WIRE(axil_awvalid_reg, 1)
   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_awaddr
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (1'b1),
      .data_in    (axil_awvalid),
      .data_out   (axil_awvalid_reg)
      );

   
   //axil write address register
   `IOB_WIRE(axil_awaddr_reg, ADDR_W)
   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_awaddr
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (axil_awvalid),
      .data_in    (axil_awaddr),
      .data_out   (axil_awaddr_reg)
      );

   
   //axil read address valid register
   `IOB_WIRE(axil_arvalid_reg, 1)
   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_araddr
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (1'b1),
      .data_in    (axil_arvalid),
      .data_out   (axil_arvalid_reg)
      );

   
   //axil read address register
   `IOB_WIRE(axil_araddr_reg, ADDR_W)
   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_araddr
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (axil_arvalid),
      .data_in    (axil_araddr),
      .data_out   (axil_araddr_reg)
      );

   //address register
   `IOB_WIRE(addr_reg, ADDR_W)
   `IOB_VAR(addr_nxt, ADDR_W)
   iob_reg #(.DATA_W(ADDR_W), .RST_VAL(0))
   iob_reg_addr
     (
      .clk        (clk),
      .arst       (rst),
      .rst        (1'b0),
      .en         (1'b1),
      .data_in    (addr_nxt),
      .data_out   (addr_reg)
      );

   `IOB_COMB begin
      if(axil_awvalid_reg)
        addr_nxt = axil_awaddr_reg;
      else if(axil_arvalid_reg)
        addr_nxt = axil_araddr_reg;
      else
        addr_nxt = addr_reg;
   end

   //output address
   `IOB_WIRE(addr_int, ADDR_W)
   assign addr = addr_int;
   
   `IOB_COMB begin
      addr = 1'b0;
      if(axil_awvalid)
        addr_int = awaddr;
      else if (axil_arvalid)
        addr_int = araddr;
      else
        addr_int = addr_reg;
   end

   //write strobe
   assign wstrb = axil_wstrb;
   
   //write data
   assign wdata = axil_wdata;

endmodule

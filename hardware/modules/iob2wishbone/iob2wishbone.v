`timescale 1ns / 1ps

module iob2wishbone #(
    parameter WB_ADDR_W = 32, // Width of address bus in bits
    parameter WB_DATA_W = 32  // Width of data bus in bits
    /*parameter WB_NON_ESSENTIAL = 0 // Enable non-essential wishbone interface signals (disabled by default)*/
  ) (
    input wire clk_i,
    input wire arst_i,
    input wire cke_i,

    //
    // Wishbone master interface
    // Note: There are more signals, however for now they are unnecessary (see https://wishbone-interconnect.readthedocs.io/en/latest/02_interface.html for more information)
    //
    output wire [WB_ADDR_W-1:0]   wishbone_addr,
    output wire [WB_DATA_W-1:0]   wishbone_data_w,
    output wire                   wishbone_we,  // Write enable output, indicates whether the current local bus cycle is a READ or WRITE cycle
    output wire [WB_DATA_W/8-1:0] wishbone_sel, // Select output array, indicates where valid data is expected on the [DAT_I()] signal array during READ cycles, and where it is placed on the [DAT_O()] signal array during WRITE cycles
    output wire                   wishbone_stb, // Strobe output, indicates a valid data transfer cycle
    output wire                   wishbone_cyc, // Cycle output, indicates that a valid bus cycle is in progress
    output wire                   wishbone_cti, // Cycle Type Idenfier
    output wire                   wishbone_bte, // Burst Type Extension
    input  wire [WB_DATA_W-1:0]   wishbone_data_r,
    input  wire                   wishbone_ack, // Acknowledge input, indicates the normal termination of a bus cycle
    input  wire                   wishbone_err, // Error input, indicates an abnormal cycle termination

    //
    // Native slave interface
    //
    input  wire                   avalid_i,
    input  wire [WB_ADDR_W-1:0]   addr_i,
    input  wire [WB_DATA_W-1:0]   wdata_i,
    input  wire [WB_DATA_W/8-1:0] wstrb_i,
    output wire [WB_DATA_W-1:0]   rdata_o,
    output wire                   rvalid_o,
    output wire                   ready_o
  );

  reg  avalid_reg;
  wire avalid_reg_rst;
  assign avalid_reg_rst = (wishbone_ack | wishbone_err);
  iob_reg_r #(1, 0) iob_reg_r_0 (clk_i, arst_i, cke_i, avalid_reg_rst, avalid_i, avalid_reg);

  assign wishbone_addr   = addr_i[WB_ADDR_W-1:0];
  assign wishbone_data_w = wdata_i;
  assign wishbone_we     = (| wstrb_i);
  assign wishbone_sel    = 1<<addr_i[1:0];
  assign wishbone_stb    = avalid_i&(~ready_o);
  assign wishbone_cyc    = avalid_i;
  assign wishbone_cti    = 3'b000;
  assign wishbone_bte    = 2'b00;
  
  assign rdata_o  = wishbone_data_r;
  assign rvalid_o = (wishbone_ack & ~wishbone_we);
  assign ready_o  = ~(avalid_reg | avalid_reg_rst);

endmodule

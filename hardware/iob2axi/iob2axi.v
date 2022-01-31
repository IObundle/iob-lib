`timescale 1ns / 1ps

`include "axi.vh"
`include "iob_lib.vh"

module iob2axi
  #(
    parameter ADDR_W = 0,
    parameter DATA_W = 0,
    // AXI-4 Full I/F parameters
    parameter AXI_ADDR_W = ADDR_W,
    parameter AXI_DATA_W = DATA_W
    )
   (
    input                  clk,
    input                  rst,

    //
    // Control I/F
    //
    input [`AXI_LEN_W-1:0] length,
    output                 iob2axi_ready,
    output                 error,

    //
    // AXI-4 Full Master I/F
    //
    `AXI4_M_IF_PORT(m_),

    //
    // Native Slave I/F
    //
    input                  valid,
    input [ADDR_W-1:0]     addr,
    input [DATA_W-1:0]     wdata,
    input [DATA_W/8-1:0]   wstrb,
    output [DATA_W-1:0]    rdata,
    output                 ready
    );

   // internal wires
   wire                    ready_rd_int, ready_wr_int;
   wire                    rd_ready, wr_ready;
   wire                    rd_error, wr_error;

   // assign outputs
   assign ready = |wstrb? ready_wr_int: ready_rd_int;
   assign iob2axi_ready = rd_ready & wr_ready;
   assign error = rd_error | wr_error;

   // AXI Read
   iob2axi_rd
     #(
       .ADDR_W(ADDR_W),
       .DATA_W(DATA_W)
       )
   iob2axi_rd0
     (
      .clk      (clk),
      .rst      (rst),

      // Control I/F
      .length   (length),
      .rd_ready (rd_ready),
      .error    (rd_error),

      // Native Slave I/F
      .valid    (valid & ~|wstrb),
      .addr     (addr),
      .rdata    (rdata),
      .ready    (ready_rd_int),

      // AXI-4 full read master I/F
      `AXI4_READ_IF_PORTMAP(m_, m_)
      );

   // AXI Write
   iob2axi_wr
     # (
        .ADDR_W(ADDR_W),
        .DATA_W(DATA_W)
        )
   iob2axi_wr0
     (
      .clk      (clk),
      .rst      (rst),

      // Control I/F
      .length   (length),
      .wr_ready (wr_ready),
      .error    (wr_error),

      // Native Slave I/F
      .valid    (valid & |wstrb),
      .addr     (addr),
      .wdata    (wdata),
      .wstrb    (wstrb),
      .ready    (ready_wr_int),

      // AXI-4 full write master I/F
      `AXI4_WRITE_IF_PORTMAP(m_, m_)
      );

endmodule

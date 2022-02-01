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
    output                 ready,
    output                 error,

    //
    // AXI-4 Full Master I/F
    //
    `AXI4_M_IF_PORT(m_),

    //
    // Native Slave I/F
    //
    input                  s_valid,
    input [ADDR_W-1:0]     s_addr,
    input [DATA_W-1:0]     s_wdata,
    input [DATA_W/8-1:0]   s_wstrb,
    output [DATA_W-1:0]    s_rdata,
    output                 s_ready
    );

   // internal wires
   wire                    s_ready_rd, s_ready_wr;
   wire                    rd_ready, wr_ready;
   wire                    rd_error, wr_error;

   // assign outputs
   assign ready = wr_ready & rd_ready;
   assign s_ready = |s_wstrb? s_ready_wr: s_ready_rd;
   assign error = rd_error | wr_error;

   // AXI Read
   iob2axi_rd
     #(
       .ADDR_W(ADDR_W),
       .DATA_W(DATA_W)
       )
   iob2axi_rd0
     (
      .clk    (clk),
      .rst    (rst),

      // Control I/F
      .length (length),
      .ready  (rd_ready),
      .error  (rd_error),

      // Native Slave I/F
      .s_valid (s_valid & ~|s_wstrb),
      .s_addr  (s_addr),
      .s_rdata (s_rdata),
      .s_ready (s_ready_rd),

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
      .clk     (clk),
      .rst     (rst),

      // Control I/F
      .length  (length),
      .ready   (wr_ready),
      .error   (wr_error),

      // Native Slave I/F
      .s_valid (s_valid & |s_wstrb),
      .s_addr  (s_addr),
      .s_wdata (s_wdata),
      .s_wstrb (s_wstrb),
      .s_ready (s_ready_wr),

      // AXI-4 full write master I/F
      `AXI4_WRITE_IF_PORTMAP(m_, m_)
      );

endmodule

`timescale 1ns / 1ps

`include "axi.vh"

module axil2native_adapter #
  (
   parameter AXIL_ADDR_W = 32, // Width of address bus in bits
   parameter AXIL_DATA_W = 32  // Width of data bus in bits
   )
   (
    input                      clk,
    input                      rst,

    //
    // AXI-4 lite slave interface
    //
    `AXI4_LITE_S_IF_PORT(s_),

    //
    // Native master interface
    //
    output reg                 valid,
    output [AXIL_ADDR_W-1:0]   addr,
    output [AXIL_DATA_W-1:0]   wdata,
    output [AXIL_DATA_W/8-1:0] wstrb,
    input [AXIL_DATA_W-1:0]    rdata,
    input                      ready
    );

   reg                         s_axil_awready_int;
   reg                         s_axil_arready_int;
   reg                         s_axil_bvalid_int;
   reg                         s_axil_rvalid_int;
   reg                         s_axil_wready_int;

   assign s_axil_awready = s_axil_awready_int;
   assign s_axil_arready = s_axil_arready_int;
   assign s_axil_bvalid = s_axil_bvalid_int;
   assign s_axil_rvalid = s_axil_rvalid_int;
   assign s_axil_wready = s_axil_wready_int;
   assign s_axil_rdata = rdata;

   // AXI IDs
   assign s_axil_bid = `AXI_ID_W'd0;
   assign s_axil_rid = `AXI_ID_W'd0;

   // Response is always OK
   assign s_axil_bresp = `AXI_RESP_W'd0;
   assign s_axil_rresp = `AXI_RESP_W'd0;

   assign addr  = s_axil_wvalid? s_axil_awaddr: s_axil_araddr;
   assign wstrb = s_axil_wvalid? s_axil_wstrb: {(AXIL_DATA_W/8){1'b0}};
   assign wdata = s_axil_wdata;

   localparam IDLE=2'h0, WRITE=2'h1, READ=2'h2, W_RESPONSE=2'h3;

   reg [1:0]                   state;
   reg [1:0]                   state_nxt;

   // State register
   always @(posedge clk) begin
      if (rst) begin
         state <= 2'b00;
      end else begin
         state <= state_nxt;
      end
   end

   wire                        rst_ready_int = (state_nxt == IDLE)? 1'b1: 1'b0;
   reg                         ready_int;
   always @(posedge clk) begin
      if (rst_ready_int) begin
         ready_int <= 1'b0;
      end else if (ready) begin
         ready_int <= 1'b1;
      end
   end

   // State machine
   always @* begin
      state_nxt = state;

      valid = 1'b0;

      s_axil_awready_int = 1'b0;
      s_axil_arready_int = 1'b0;
      s_axil_bvalid_int = 1'b0;
      s_axil_rvalid_int = 1'b0;
      s_axil_wready_int = 1'b0;

      case (state)
        IDLE: begin
           if (s_axil_awvalid) begin
              state_nxt = WRITE;
           end else if (s_axil_arvalid) begin
              state_nxt = READ;
           end
        end
        WRITE: begin
           if (ready) begin
              state_nxt = W_RESPONSE;
           end

           valid = ~ready;

           s_axil_awready_int = ready;
           s_axil_wready_int  = ready;
        end
        READ: begin
           if ((ready| ready_int) & s_axil_rready) begin
              state_nxt = IDLE;
           end

           valid = ~(ready | ready_int);

           s_axil_arready_int = ready & s_axil_arvalid;
           s_axil_rvalid_int  = ready | ready_int;
        end
        W_RESPONSE: begin
           if (s_axil_bready) begin
              state_nxt = IDLE;
           end

           s_axil_bvalid_int = 1'b1;
        end
      endcase
   end

endmodule

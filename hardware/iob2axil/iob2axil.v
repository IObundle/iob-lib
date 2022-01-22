`timescale 1ns / 1ps

`include "axi.vh"

module native2axil_adapter #
  (
   parameter AXIL_ADDR_W = 32, // Width of address bus in bits
   parameter AXIL_DATA_W = 32  // Width of data bus in bits
   )
   (
    input                     clk,
    input                     rst,

    //
    // AXI-4 lite master interface
    //
    `AXI4_LITE_M_IF_PORT(m_),

    //
    // Native slave interface
    //
    input                     valid,
    input [AXIL_ADDR_W-1:0]   addr,
    input [AXIL_DATA_W-1:0]   wdata,
    input [AXIL_DATA_W/8-1:0] wstrb,
    output [AXIL_DATA_W-1:0]  rdata,
    output reg                ready
    );

   reg                        m_axil_awvalid_int;
   reg                        m_axil_arvalid_int;
   reg                        m_axil_bready_int;
   reg                        m_axil_rready_int;
   reg                        m_axil_wvalid_int;

   assign m_axil_awvalid = m_axil_awvalid_int;
   assign m_axil_arvalid = m_axil_arvalid_int;
   assign m_axil_bready  = m_axil_bready_int;
   assign m_axil_rready  = m_axil_rready_int;
   assign m_axil_wvalid  = m_axil_wvalid_int;
   assign m_axil_awaddr  = addr;
   assign m_axil_araddr  = addr;
   assign m_axil_wdata   = wdata;
   assign m_axil_wstrb   = wstrb;

   // AXI IDs
   assign m_axil_awid = `AXI_ID_W'd0;
   assign m_axil_wid  = `AXI_ID_W'd0;
   assign m_axil_arid = `AXI_ID_W'd0;

   // Protection types
   assign m_axil_awprot = `AXI_PROT_W'd2;
   assign m_axil_arprot = `AXI_PROT_W'd2;

   // Quality of services
   assign m_axil_awqos = `AXI_QOS_W'd0;
   assign m_axil_arqos = `AXI_QOS_W'd0;

   assign rdata = m_axil_rdata;

   localparam IDLE=2'h0, WRITE=2'h1, READ=2'h2, W_RESPONSE=2'h3;

   reg [1:0]                  state;
   reg [1:0]                  state_nxt;

   // State register
   always @(posedge clk) begin
      if (rst) begin
         state <= 2'b00;
      end else begin
         state <= state_nxt;
      end
   end

   wire                       rst_valid_int = (state_nxt == IDLE)? 1'b1: 1'b0;
   reg                        awvalid_int;
   reg                        arvalid_int;
   always @(posedge clk) begin
      if (rst_valid_int) begin
         awvalid_int <= 1'b1;
         arvalid_int <= 1'b1;
      end else begin
         if (m_axil_awready) begin
            awvalid_int <= 1'b0;
         end
         if (m_axil_arready) begin
            arvalid_int <= 1'b0;
         end
      end
   end

   // State machine
   always @* begin
      state_nxt = state;

      ready = 1'b0;

      m_axil_awvalid_int = 1'b0;
      m_axil_arvalid_int = 1'b0;
      m_axil_bready_int = 1'b0;
      m_axil_rready_int = 1'b0;
      m_axil_wvalid_int = 1'b0;

      case (state)
        IDLE: begin
           if (valid) begin
              if (|wstrb) begin
                 state_nxt = WRITE;
              end else begin
                 state_nxt = READ;
              end
           end
        end
        WRITE: begin
           if (m_axil_wready) begin
              state_nxt = W_RESPONSE;
           end

           ready = m_axil_wready;

           m_axil_awvalid_int = awvalid_int;
           m_axil_wvalid_int  = 1'b1;
        end
        READ: begin
           if (m_axil_rvalid) begin
              state_nxt = IDLE;
           end

           ready = m_axil_rvalid;

           m_axil_arvalid_int = arvalid_int;
           m_axil_rready_int  = 1'b1;
        end
        W_RESPONSE: begin
           if (m_axil_bvalid) begin
              state_nxt = IDLE;
           end

           m_axil_bready_int = 1'b1;
        end
      endcase
   end

endmodule

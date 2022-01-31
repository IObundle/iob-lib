`timescale 1ns / 1ps

`include "axi.vh"

module iob2axi_wr
  #(
    parameter ADDR_W = 0,
    parameter DATA_W = 0
    )
   (
    input                  clk,
    input                  rst,

    //
    // Control I/F
    //
    input [`AXI_LEN_W-1:0] length,
    output reg             ready,
    output                 error,

    //
    // Native Slave I/F
    //
    input                  s_valid,
    input [ADDR_W-1:0]     s_addr,
    input [DATA_W-1:0]     s_wdata,
    input [DATA_W/8-1:0]   s_wstrb,
    output                 s_ready,

    //
    // AXI-4 Full Master Write I/F
    //

    `AXI4_M_WRITE_IF_PORT(m_)
    );

   localparam axi_awsize = $clog2(DATA_W/8);

   localparam ADDR_HS=2'h0, WRITE=2'h1, W_RESPONSE=2'h2;

   // State signals
   reg [1:0]               state, state_nxt;

   // Counter and error signals
   reg [`AXI_LEN_W:0]      counter_int, counter_int_nxt;
   reg                     error_int, error_nxt;

   // Write ready
   reg                     ready_nxt;

   reg                     m_axi_awvalid_int, m_axi_awvalid_reg;
   reg                     m_axi_wvalid_int;
   reg                     m_axi_wlast_int;

   // Control register signals
   reg [ADDR_W-1:0]        addr_reg;
   reg [`AXI_LEN_W-1:0]    length_reg;

   reg                     s_ready_int;

   assign s_ready = s_ready_int;
   assign error = error_int;

   // Write address
   assign m_axi_awid = `AXI_ID_W'd0;
   assign m_axi_awvalid = m_axi_awvalid_reg;
   assign m_axi_awaddr = addr_reg;
   assign m_axi_awlen = length_reg;
   assign m_axi_awsize = axi_awsize;
   assign m_axi_awburst = `AXI_BURST_W'd1;
   assign m_axi_awlock = `AXI_LOCK_W'd0;
   assign m_axi_awcache = `AXI_CACHE_W'd2;
   assign m_axi_awprot = `AXI_PROT_W'd2;
   assign m_axi_awqos = `AXI_QOS_W'd0;

   // Write
   assign m_axi_wid = `AXI_ID_W'd0;
   assign m_axi_wvalid = m_axi_wvalid_int;
   assign m_axi_wdata = s_wdata;
   assign m_axi_wstrb = s_wstrb;
   assign m_axi_wlast = m_axi_wlast_int;

   // Write response
   assign m_axi_bready = m_axi_bready_int;

   // Delay register
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         m_axi_awvalid_reg <= 1'b0;
      end else begin
         m_axi_awvalid_reg <= m_axi_awvalid_int;
      end
   end

   // Counter, error and ready registers
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         counter_int <= `AXI_LEN_W'd0;
         error_int <= 1'b0;
         ready <= 1'b1;
      end else begin
         counter_int <= counter_int_nxt;
         error_int <= error_nxt;
         ready <= ready_nxt;
      end
   end

   // Control registers
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         addr_reg <= 1'b0;
         length_reg <= 1'b0;
      end else if (state == ADDR_HS) begin
         addr_reg <= s_addr;
         length_reg <= length;
      end
   end

   // Compute awvalid
   wire                    rst_valid_int = (state_nxt == ADDR_HS)? 1'b1: 1'b0;
   reg                     awvalid_int;

   always @(posedge clk, posedge rst) begin
      if (rst)
        awvalid_int <= 1'b0;
      else if (rst_valid_int) begin
         awvalid_int <= 1'b1;
      end else if (m_axi_awready) begin
         awvalid_int <= 1'b0;
      end
   end

   //
   // FSM
   //

   // State register
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         state <= ADDR_HS;
      end else begin
         state <= state_nxt;
      end
   end

   // State machine
   always @* begin
      state_nxt = state;

      error_nxt = error_int;
      ready_nxt = 1'b0;
      counter_int_nxt = counter_int;

      s_ready_int = 1'b0;

      m_axi_awvalid_int = 1'b0;
      m_axi_wvalid_int = 1'b0;
      m_axi_wlast_int = 1'b0;
      m_axi_bready_int = 1'b1;

      case (state)
        // Write address handshake
        ADDR_HS: begin
           counter_int_nxt = `AXI_LEN_W'd0;
           ready_nxt = 1'b1;

           if (s_valid) begin
              state_nxt = WRITE;

              m_axi_awvalid_int = 1'b1;
              ready_nxt = 1'b0;
           end
        end
        // Write data
        WRITE: begin
           s_ready_int = m_axi_wready;

           m_axi_awvalid_int = awvalid_int;
           m_axi_wvalid_int = s_valid;

           if (m_axi_wready & s_valid) begin
              if (counter_int == length_reg) begin
                 m_axi_wlast_int = 1'b1;
                 state_nxt = W_RESPONSE;
              end

              counter_int_nxt = counter_int + 1'b1;
           end
        end
        // Write response
        W_RESPONSE: begin
           if (m_axi_bvalid) begin
              error_nxt = |m_axi_bresp;

              state_nxt = ADDR_HS;
           end
        end
        default: state_nxt = ADDR_HS;
      endcase
   end

endmodule

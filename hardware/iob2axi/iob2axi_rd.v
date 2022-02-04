`timescale 1ns / 1ps

`include "axi.vh"

module iob2axi_rd
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
    output reg             ready,
    output reg             error,

    //
    // Native Slave I/F
    //
    input                   s_valid,
    input [ADDR_W-1:0]      s_addr,
    output reg [DATA_W-1:0] s_rdata,
    output reg              s_ready,

    //
    // AXI-4 Full Master Read I/F
    //

    `AXI4_M_READ_IF_PORT(m_)
    );

   localparam axi_arsize = $clog2(DATA_W/8);

   localparam ADDR_HS=1'h0, READ=1'h1;

   // State signals
   reg                     state, state_nxt;

   // Counter and error signals
   reg [`AXI_LEN_W-1:0]    counter, counter_nxt;
   reg                     error_nxt;

   // Read ready
   reg                     ready_nxt;

   reg                     m_axi_arvalid_int;
   reg                     m_axi_rready_int;

   // Control register signals
   reg [`AXI_LEN_W-1:0]    length_reg;

   reg                     s_ready_int;

   // Read address
   assign m_axi_arid = `AXI_ID_W'b0;
   assign m_axi_arvalid = m_axi_arvalid_int;
   assign m_axi_araddr = s_addr;
   assign m_axi_arlen = length;
   assign m_axi_arsize = axi_arsize;
   assign m_axi_arburst = `AXI_BURST_W'd1;
   assign m_axi_arlock = `AXI_LOCK_W'b0;
   assign m_axi_arcache = `AXI_CACHE_W'd2;
   assign m_axi_arprot = `AXI_PROT_W'd2;
   assign m_axi_arqos = `AXI_QOS_W'd0;

   // Read
   assign m_axi_rready = m_axi_rready_int;

   // Counter, error and ready registers
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         counter <= `AXI_LEN_W'd0;
         error <= 1'b0;
         ready <= 1'b1;
         s_ready <= 1'b0;
         s_rdata <= {DATA_W{1'd0}};
      end else begin
         counter <= counter_nxt;
         error <= error_nxt;
         ready <= ready_nxt;
         s_ready <= s_ready_int;
         s_rdata <= m_axi_rdata;
      end
   end

   // Control registers
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         length_reg <= `AXI_LEN_W'd0;
      end else if (state == ADDR_HS) begin
         length_reg <= length;
      end
   end

   wire                    rst_valid_int = (state_nxt == ADDR_HS)? 1'b1: 1'b0;
   reg                     arvalid_int;

   always @(posedge clk, posedge rst) begin
      if(rst)
        arvalid_int <= 1'b0;
      else if (rst_valid_int) begin
         arvalid_int <= 1'b1;
      end else if (m_axi_arready) begin
         arvalid_int <= 1'b0;
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

      error_nxt = error;
      ready_nxt = 1'b0;
      counter_nxt = counter;

      s_ready_int = 1'b0;

      m_axi_arvalid_int = 1'b0;
      m_axi_rready_int = 1'b0;

      case (state)
        // Read address handshake
        ADDR_HS: begin
           counter_nxt = `AXI_LEN_W'd0;
           ready_nxt = 1'b1;

           if (s_valid) begin
              m_axi_arvalid_int = 1'b1;

              if(m_axi_arready) begin
                 state_nxt = READ;

                 ready_nxt = 1'b0;
              end
           end
        end
        // Read data
        READ: begin
           s_ready_int = (s_valid & m_axi_rvalid);

           m_axi_arvalid_int = arvalid_int;
           m_axi_rready_int = s_valid;

           if (m_axi_rvalid) begin
              if (s_valid & counter == length_reg) begin
                 error_nxt = ~m_axi_rlast;

                 state_nxt = ADDR_HS;
              end

              if (s_valid) begin
                 counter_nxt = counter + 1'b1;
              end
           end
        end
      endcase
   end

endmodule

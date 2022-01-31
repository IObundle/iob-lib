`timescale 1ns / 1ps

`include "axi.vh"

module iob2axi_rd
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
    output reg             rd_ready,
    output                 error,

    //
    // Native Slave I/F
    //
    output reg             ready,
    input                  valid,
    input [ADDR_W-1:0]     addr,
    output [DATA_W-1:0]    rdata,
   
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
   reg [`AXI_LEN_W-1:0]    counter_int, counter_int_nxt;
   reg                     error_int, error_nxt;

   // Read ready
   reg                     rd_ready_nxt;

   reg                     m_axi_arvalid_int;

   // Control register signals
   reg [ADDR_W-1:0]        addr_reg;
   reg [`AXI_LEN_W-1:0]    length_reg;

   assign error = error_int;

   // Read address
   assign m_axi_arid = `AXI_ID_W'b0;
   assign m_axi_arvalid = m_axi_arvalid_reg;
   assign m_axi_araddr = addr_reg;
   assign m_axi_arlen = length_reg;
   assign m_axi_arsize = axi_arsize;
   assign m_axi_arburst = `AXI_BURST_W'd1;
   assign m_axi_arlock = `AXI_LOCK_W'b0;
   assign m_axi_arcache = `AXI_CACHE_W'd2;
   assign m_axi_arprot = `AXI_PROT_W'd2;
   assign m_axi_arqos = `AXI_QOS_W'd0;

   // Read
   assign rdata = m_axi_rdata;
   assign m_axi_rready = m_axi_rready_int;

   // Delay register
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         m_axi_arvalid_reg <= 1'b0;
      end else begin
         m_axi_arvalid_reg <= m_axi_arvalid_int;
      end
   end

   // Counter, error and addr valid registers
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         counter_int <= `AXI_LEN_W'd0;
         error_int <= 1'b0;
         rd_ready <= 1'b1;
      end else begin
         counter_int <= counter_int_nxt;
         error_int <= error_nxt;
         rd_ready <= rd_ready_nxt;
      end
   end

   // Control registers
   always @(posedge clk, posedge rst) begin
      if (rst) begin
         addr_reg <= {ADDR_W{1'b0}};
         length_reg <= `AXI_LEN_W'd0;
      end else if (state == ADDR_HS) begin
         addr_reg <= addr;
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

      error_nxt = error_int;
      rd_ready_nxt = 1'b0;
      counter_int_nxt = counter_int;

      ready = 1'b0;

      m_axi_arvalid_int = 1'b0;
      m_axi_rready_int = 1'b0;

      case (state)
        // Read address handshake
        ADDR_HS: begin
           counter_int_nxt = `AXI_LEN_W'd0;
           rd_ready_nxt = 1'b1;

           if (valid) begin
              state_nxt = READ;

              m_axi_arvalid_int = 1'b1;
              rd_ready_nxt = 1'b0;
           end
        end
        // Read data
        READ: begin
           ready = m_axi_rvalid;

           m_axi_arvalid_int = arvalid_int;
           m_axi_rready_int = valid;

           if (m_axi_rvalid) begin
              if (counter_int == length_reg) begin
                 error_nxt = ~m_axi_rlast;

                 state_nxt = ADDR_HS;
              end

              if (valid) begin
                 counter_int_nxt = counter_int + 1'b1;
              end
           end
        end
      endcase
   end

endmodule

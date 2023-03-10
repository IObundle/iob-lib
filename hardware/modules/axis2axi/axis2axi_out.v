`timescale 1ns / 1ps

`include "iob_lib.vh"
`include "axi.vh"

module axis2axi_out #(
   parameter AXI_ADDR_W = 0,
   parameter AXI_DATA_W = 32, // We currently only support 4 byte transfer
   parameter BURST_W = 0
)(
   // Configuration
   `IOB_INPUT(addr_out_i,AXI_ADDR_W),
   `IOB_INPUT(out_length_i,AXI_ADDR_W),
   `IOB_INPUT(set_out_config_i,1),

   // Axi stream input
   `IOB_OUTPUT(axis_out_data_o,AXI_DATA_W),
   `IOB_OUTPUT(axis_out_valid_o,1),
   `IOB_INPUT(axis_out_ready_i,1),

   // Axi master interface
   `include "m_axi_read_m_port.vh"

   `IOB_INPUT(clk_i,1),
   `IOB_INPUT(cke_i,1),
   `IOB_INPUT(rst_i,1)
);

localparam BURST_SIZE = 2**BURST_W;
localparam BUFFER_W = BURST_W + 1;
localparam BUFFER_SIZE = 2**BUFFER_W;

// Constants
assign m_axi_arid = `AXI_ID_W'd0;
assign m_axi_arsize  = `AXI_SIZE_W'd2;
assign m_axi_arburst = `AXI_BURST_W'd1;
assign m_axi_arlock  = `AXI_LOCK_W'b0;
assign m_axi_arcache = `AXI_CACHE_W'd2;
assign m_axi_arprot  = `AXI_PROT_W'd2;
assign m_axi_arqos   = `AXI_QOS_W'd0;

// Regs to assign to outputs
reg arvalid_int;
reg [23:0] araddr_int;
reg [`AXI_LEN_W-1:0] arlen_int;

// State regs
reg [1:0] state;
reg [AXI_ADDR_W-1:0] current_address;
reg [AXI_ADDR_W-1:0] current_length;

// Logical wires and combinatorial regs
wire doing_global_transfer = (state != 2'h0);
wire doing_local_transfer = (state == 2'h3);
wire [15:0] boundary_transfer_len = (16'h1000 - current_address[11:0]) >> 2;
wire normal_burst_possible = (current_length >= BURST_SIZE);
wire last_burst_possible = (current_length < BURST_SIZE);

// Combinatorial
reg [BUFFER_SIZE-1:0] burst_size;
always @*
begin
   burst_size = 0;
   
   if(last_burst_possible) begin
      if(current_length < boundary_transfer_len)
         burst_size = current_length;
      else
         burst_size = boundary_transfer_len;
   end else if(boundary_transfer_len < BURST_SIZE)
      burst_size = boundary_transfer_len;
   else if(normal_burst_possible)
      burst_size = BURST_SIZE;
end

// Assignment to outputs
assign axis_out_data_o = m_axi_rdata;
assign axis_out_valid_o = (doing_local_transfer && m_axi_rvalid);
assign m_axi_rready = (doing_local_transfer && axis_out_ready_i);

assign m_axi_araddr = araddr_int;
assign m_axi_arlen = arlen_int;
assign m_axi_arvalid = arvalid_int;

// State machine
localparam WAIT_START=2'h0, BEGIN_LOCAL=2'h1, TRANSFER=2'h2, END_LOCAL=2'h3;
always @(posedge clk_i,posedge rst_i)
begin
   if(rst_i) begin
      state <= WAIT_START;
      current_address <= 0;
      arvalid_int <= 0;
      araddr_int <= 0;
      arlen_int <= 0;
      current_length <= 0;
   end else begin
      case(state)
      WAIT_START: if(set_out_config_i) begin
         current_address <=  addr_out_i;
         current_length <= out_length_i;
         state <= BEGIN_LOCAL;
      end
      BEGIN_LOCAL: begin
         arvalid_int <= 1'b1;
         araddr_int <= current_address;
         arlen_int <= burst_size - 1;
         current_address <= current_address + (burst_size << 2);
         current_length <= current_length - burst_size;
         state <= TRANSFER;
      end
      TRANSFER: if(m_axi_arready) begin
         arvalid_int <= 1'b0;
         state <= END_LOCAL;
      end
      END_LOCAL: if(m_axi_rlast && m_axi_rvalid && m_axi_rready) begin
         if(current_length == 0)
            state <= WAIT_START;
         else 
            state <= BEGIN_LOCAL;
      end
      endcase
   end
end

endmodule
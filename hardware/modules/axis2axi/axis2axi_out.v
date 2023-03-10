`timescale 1ns / 1ps

`include "iob_lib.vh"

module axis2axi_out #(
   parameter AXI_ADDR_W = 0,
   parameter AXI_DATA_W = 32, // We currently only support 4 byte transfer
   parameter AXI_LEN_W = 8,
   parameter AXI_ID_W = 1,
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
   `include "iob_axi_m_read_port.vh"

   `IOB_INPUT(clk_i,1),
   `IOB_INPUT(cke_i,1),
   `IOB_INPUT(rst_i,1),
   `IOB_INPUT(arst_i,1)
);

localparam BURST_SIZE = 2**BURST_W;
localparam BUFFER_W = BURST_W + 1;
localparam BUFFER_SIZE = 2**BUFFER_W;

// Constants
assign axi_arid_o = 0;
assign axi_arsize_o  = 2;
assign axi_arburst_o = 1;
assign axi_arlock_o  = 0;
assign axi_arcache_o = 2;
assign axi_arprot_o  = 2;
assign axi_arqos_o   = 0;

// Regs to assign to outputs
reg arvalid_int;
reg [23:0] araddr_int;
wire [BURST_W:0] arlen_int;

// State regs
reg [1:0] state_nxt;
reg [AXI_ADDR_W-1:0] next_address,next_length;

// Instantiation wires
wire [AXI_ADDR_W-1:0] current_address,current_length;
wire [1:0] state;

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
wire [BURST_W:0] transfer_len = burst_size - 1;

// Assignment to outputs
assign axis_out_data_o = axi_rdata_i;
assign axis_out_valid_o = (doing_local_transfer && axi_rvalid_i);
assign axi_rready_o = (doing_local_transfer && axis_out_ready_i);

assign axi_araddr_o = araddr_int;
assign axi_arlen_o = arlen_int;
assign axi_arvalid_o = arvalid_int;

localparam WAIT_START=2'h0, BEGIN_LOCAL=2'h1, TRANSFER=2'h2, END_LOCAL=2'h3;
`IOB_COMB
begin
   state_nxt = state;
   arvalid_int = 1'b0;
   next_address = current_address;
   next_length = current_length;

   case(state)
   WAIT_START: if(set_out_config_i) begin
      next_address = addr_out_i;
      next_length = out_length_i;
      state_nxt = BEGIN_LOCAL;
   end
   BEGIN_LOCAL: begin
      next_length = current_length - burst_size;
         state_nxt = TRANSFER;
   end
   TRANSFER: begin
      araddr_int = current_address;
      arvalid_int = 1'b1;
      if(axi_arready_i)
         state_nxt = END_LOCAL;
   end
   END_LOCAL: if(axi_rlast_i && axi_rvalid_i && axi_rready_o) begin
      next_address = current_address + ((axi_arlen_o + 1) << 2);
      if(current_length == 0)
         state_nxt = WAIT_START;
      else 
         state_nxt = BEGIN_LOCAL;
   end
   endcase
end

iob_reg_re #(BURST_W+1,0) _1 (clk_i,arst_i,cke_i,rst_i,(state == BEGIN_LOCAL),transfer_len,arlen_int);
iob_reg_r #(AXI_ADDR_W,0) _2 (clk_i,arst_i,cke_i,rst_i,next_address,current_address);
iob_reg_r #(AXI_ADDR_W,0) _3 (clk_i,arst_i,cke_i,rst_i,next_length,current_length);
iob_reg_r #(2,0) _4 (clk_i,arst_i,cke_i,rst_i,state_nxt,state);

endmodule

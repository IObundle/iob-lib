`timescale 1ns / 1ps

`include "iob_lib.vh"
`include "axi.vh"

module axis2axi_in #( 
   parameter AXI_ADDR_W = 0,
   parameter AXI_DATA_W = 32, // We currently only support 4 byte transfer
   parameter BURST_W = 0
)(
   // Buffer memory external interfaces
   `IOB_OUTPUT(ext_mem_w_en_o, 1),
   `IOB_OUTPUT(ext_mem_w_data_o, AXI_DATA_W),
   `IOB_OUTPUT(ext_mem_w_addr_o, BUFFER_W),
   `IOB_OUTPUT(ext_mem_r_en_o, 1),
   `IOB_OUTPUT(ext_mem_r_addr_o, BUFFER_W),
   `IOB_INPUT(ext_mem_r_data_i, AXI_DATA_W),
   
   // Configuration
   `IOB_INPUT(addr_in_i,AXI_ADDR_W),
   `IOB_INPUT(set_in_config_i,1),

   // Axi stream input
   `IOB_INPUT(axis_in_data_i,AXI_DATA_W),
   `IOB_INPUT(axis_in_valid_i,1),
   `IOB_OUTPUT(axis_in_ready_o,1),

   // Axi master interface
   `include "m_axi_write_m_port.vh"

   `IOB_INPUT(clk_i,1),
   `IOB_INPUT(cke_i,1),
   `IOB_INPUT(rst_i,1)
);

localparam BURST_SIZE = 2**BURST_W;
localparam BUFFER_W = BURST_W + 1;
localparam BUFFER_SIZE = 2**BUFFER_W;

// Constants
assign m_axi_awid = `AXI_ID_W'd0;
assign m_axi_awsize  = `AXI_SIZE_W'd2;
assign m_axi_awburst = `AXI_BURST_W'd1;
assign m_axi_awlock  = `AXI_LOCK_W'b0;
assign m_axi_awcache = `AXI_CACHE_W'd2;
assign m_axi_awprot  = `AXI_PROT_W'd2;
assign m_axi_awqos   = `AXI_QOS_W'd0;
assign m_axi_wstrb = 4'b1111;
assign m_axi_bready = 1'b1;
assign m_axi_wid = 1'b0;

// Regs to assign to outputs
reg awvalid_int;
reg [23:0] awaddr_int;
reg [`AXI_LEN_W-1:0] awlen_int;
reg wvalid_int;

// State regs
reg [1:0] state;

reg [AXI_ADDR_W-1:0] current_address;
reg [BURST_SIZE-1:0] transfer_count;

// Instantiation wires
wire [AXI_DATA_W-1:0] fifo_data;
wire fifo_empty,fifo_full;
wire [BUFFER_W:0] fifo_level;

// Logical wires
wire doing_transfer = (state != 2'b00);
wire normal_burst_possible = (fifo_level >= BURST_SIZE);
wire last_burst_possible = (fifo_level > 0 && fifo_level < BURST_SIZE && !axis_in_valid_i);
wire start_transfer = (normal_burst_possible || last_burst_possible) && !doing_transfer;
wire read_next = (m_axi_wready && !m_axi_wlast);
wire [15:0] boundary_transfer_len = (16'h1000 - current_address[11:0]) >> 2;
wire last_transfer = (transfer_count == m_axi_awlen);
wire fifo_read_enable = (read_next || start_transfer);  // Start_transfer puts the first valid data on r_data and offsets fifo read by one cycle which lines up perfectly with the way the m_axi_wready signal works

// Combinatorial
reg [BURST_W:0] burst_size;
always @*
begin
   burst_size = 0;
   
   if(last_burst_possible) begin
      if(fifo_level < boundary_transfer_len)
         burst_size = fifo_level;
      else
         burst_size = boundary_transfer_len;
   end else if(boundary_transfer_len < BURST_SIZE)
      burst_size = boundary_transfer_len;
   else if(normal_burst_possible)
      burst_size = BURST_SIZE;
end

// Assignment to outputs
assign m_axi_awvalid = awvalid_int;
assign m_axi_awaddr = awaddr_int;
assign m_axi_awlen = awlen_int;
assign m_axi_wvalid = wvalid_int;
assign m_axi_wdata = fifo_data;
assign m_axi_wlast = last_transfer;
assign m_axi_wdata = fifo_data;

assign axis_in_ready_o = !fifo_full;

// State machine
localparam WAIT_DATA=2'h0, START_TRANSFER=2'h1, TRANSFER=2'h2, WAIT_BRESP=2'h3;
always @(posedge clk_i,posedge rst_i)
begin
   if(rst_i) begin
      awvalid_int <= 0;
      awaddr_int <= 0;
      awlen_int <= 0;
      wvalid_int <= 0;
      current_address <= 0;
      state <= 0;
      transfer_count <= 0;
   end else begin
      if(set_in_config_i) begin
         current_address <= addr_in_i;
      end

      case (state)
      WAIT_DATA: if(start_transfer) begin
         awvalid_int <= 1'b1;
         awaddr_int <= current_address;
         current_address <= current_address + (burst_size << 2);
         awlen_int <= burst_size - 1;
         state <= START_TRANSFER;
         transfer_count <= 0;
      end
      START_TRANSFER: if(m_axi_awready) begin
         awvalid_int <= 1'b0;
         wvalid_int <= 1'b1; // Since we can only send less or equal to the amount present on our FIFO, we can set m_axi_wvalid to 1. We always have a value to send 
         state <= TRANSFER;
      end
      TRANSFER: if(m_axi_wready && m_axi_wvalid) begin
         transfer_count <= transfer_count + 1;
         if(last_transfer) begin 
            wvalid_int <= 1'b0;
            state <= WAIT_BRESP;
         end
      end
      WAIT_BRESP: if(m_axi_bvalid) begin
         // Do something with the response?
         state <= WAIT_DATA;
      end
      endcase
   end
end

iob_fifo_sync
  #(.W_DATA_W(AXI_DATA_W),
   .R_DATA_W(AXI_DATA_W),
   .ADDR_W(BUFFER_W)
   )
   fifo
   (
   //write port
   .ext_mem_w_en_o(ext_mem_w_en_o),
   .ext_mem_w_data_o(ext_mem_w_data_o),
   .ext_mem_w_addr_o(ext_mem_w_addr_o),
   //read port
   .ext_mem_r_en_o(ext_mem_r_en_o),
   .ext_mem_r_addr_o(ext_mem_r_addr_o),
   .ext_mem_r_data_i(ext_mem_r_data_i),
   
   //write port
   .w_en_i(axis_in_valid_i),
   .w_data_i(axis_in_data_i),
   .w_full_o(fifo_full),

   //read port
   .r_en_i(fifo_read_enable),
   .r_data_o(fifo_data),
   .r_empty_o(fifo_empty),

   //FIFO level
   .level_o(fifo_level),

   .clk_i(clk_i),
   .cke_i(cke_i),
   .rst_i(rst_i),
   .arst_i(1'b0)
   );

endmodule
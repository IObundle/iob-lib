`timescale 1ns / 1ps

// Simple AXI Stream (AXIS) to AXI adapter
// Address (and length for reads) are set by filling the associated configuration wires and then asserting the set_*_config_i wires for a cycle.
// This unit breaks down an AXIS stream into multiple bursts of maximum size (2**BURST_W). 
// At the end of each burst, the address is updated automatically providing a transparent way of reading and writing to a AXI device.

// For AXIS In streams, the unit uses a FIFO transparently. The unit flushes the FIFO when axis_in_valid_i is deasserted. 

// For AXIS Out streams, the length is required but it can be any value, it is not limited to the AXI maximum length.
// The AXIS Out stream is activated after asserting set_out_config_i. Afterwards, the AXIS Out stream must acknowledge the full amount of data requested otherwise the unit will block.

module axis2axi
   #( 
      parameter AXI_ADDR_W = 0,
      parameter AXI_DATA_W = 32, // We currently only support 4 byte transfer
      parameter AXI_LEN_W = 8,
      parameter AXI_ID_W = 1,
      parameter BURST_W = 0,
      parameter BUFFER_W = BURST_W + 1
)(
   // Configuration
   `IOB_INPUT(addr_in_i,AXI_ADDR_W),
   `IOB_INPUT(set_in_config_i,1),

   `IOB_INPUT(addr_out_i,AXI_ADDR_W),
   `IOB_INPUT(out_length_i,AXI_ADDR_W),
   `IOB_INPUT(set_out_config_i,1), // Setting this to 1 will start the transfer. Deassert before transfer ends otherwise it will a new one.

   // Buffer memory external interfaces
   `IOB_OUTPUT(ext_mem_w_en_o, 1),
   `IOB_OUTPUT(ext_mem_w_data_o, AXI_DATA_W),
   `IOB_OUTPUT(ext_mem_w_addr_o, BUFFER_W),
   `IOB_OUTPUT(ext_mem_r_en_o, 1),
   `IOB_OUTPUT(ext_mem_r_addr_o, BUFFER_W),
   `IOB_INPUT(ext_mem_r_data_i, AXI_DATA_W),

   // AXI stream input
   `IOB_INPUT(axis_in_data_i,AXI_DATA_W),
   `IOB_INPUT(axis_in_valid_i,1),
   `IOB_OUTPUT(axis_in_ready_o,1),

   // AXI stream output
   `IOB_OUTPUT(axis_out_data_o,AXI_DATA_W),
   `IOB_OUTPUT(axis_out_valid_o,1),
   `IOB_INPUT(axis_out_ready_i,1),

   // AXI master interface
   `include "iob_axi_m_port.vh"

   `IOB_INPUT(clk_i,1),
   `IOB_INPUT(cke_i,1),
   `IOB_INPUT(rst_i,1),
   `IOB_INPUT(arst_i,1)
);

axis2axi_in #(
   .AXI_ADDR_W(AXI_ADDR_W),
   .AXI_DATA_W(AXI_DATA_W),
   .BURST_W(BURST_W)
   )
   axis2axi_in_inst
   (
   .addr_in_i(addr_in_i),
   .set_in_config_i(set_in_config_i),
   
   .ext_mem_w_en_o(ext_mem_w_en_o),
   .ext_mem_w_data_o(ext_mem_w_data_o),
   .ext_mem_w_addr_o(ext_mem_w_addr_o),
   .ext_mem_r_en_o(ext_mem_r_en_o),
   .ext_mem_r_addr_o(ext_mem_r_addr_o),
   .ext_mem_r_data_i(ext_mem_r_data_i),

   .axis_in_data_i(axis_in_data_i),
   .axis_in_valid_i(axis_in_valid_i),
   .axis_in_ready_o(axis_in_ready_o),

   `include "iob_axi_m_m_write_portmap.vh"
   
   .clk_i(clk_i),
   .cke_i(cke_i),
   .rst_i(rst_i),
   .arst_i(arst_i)
   );

axis2axi_out #(
   .AXI_ADDR_W(AXI_ADDR_W),
   .AXI_DATA_W(AXI_DATA_W),
   .BURST_W(BURST_W)
   )
   axis2axi_out_inst
   (
   .addr_out_i(addr_out_i),
   .out_length_i(out_length_i),
   .set_out_config_i(set_out_config_i),
   
   .axis_out_data_o(axis_out_data_o),
   .axis_out_valid_o(axis_out_valid_o),
   .axis_out_ready_i(axis_out_ready_i),

   `include "iob_axi_m_m_read_portmap.vh"
   
   .clk_i(clk_i),
   .cke_i(cke_i),
   .rst_i(rst_i),
   .arst_i(arst_i)
   );

endmodule

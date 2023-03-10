`timescale 1ns / 1ps

// Simple AXI Stream (AXIS) to AXI adapter
// Address (and length for reads) are set by using the config_in or config_out interfaces. They both use a AXI like handshake process (when valid && ready == 1, store and initiate transfer).
// The config_*_ready_o interfaces can also be used directly to probe the state of the transfer. When asserted, they indicate that the unit does not currently have any AXI connection active or no data in the FIFO to flush.

// This unit breaks down an AXI Stream into multiple bursts of AXI. For AXIS IN, this is performed transparently. For AXIS OUT, a length argument is required

// AXIS IN:
// After configuring the AXIS IN stream, the axis_in interface can be used. There is no limit to the amount of data that can be sent. This unit breaks down data into multiple bursts as required and also handles 4k boundaries.

// AXIS OUT:
// After configuring the AXIS OUT stream, the axis_out interface can be used. The unit will produce a length amount of data. 
// Length is given as the amount of dwords. A length of 1 means that one transfer is performed. (A length of zero does nothing)
// If the axis_out interface is stalled permanently before completing the full transfer, the unit might block the entire system, as it will continue to keep a AXI connection alive.
// If for some reason the user realises that it requested a length bigger then need, the user still needs to keep consuming data out of the axis_out interface. Only when config_out_ready_o is asserted is the transfer fully completed

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
   `IOB_INPUT(config_in_addr_i,AXI_ADDR_W),
   `IOB_INPUT(config_in_valid_i,1),
   `IOB_OUTPUT(config_in_ready_o,1),

   `IOB_INPUT(config_out_addr_i,AXI_ADDR_W),
   `IOB_INPUT(config_out_length_i,AXI_ADDR_W),
   `IOB_INPUT(config_out_valid_i,1),
   `IOB_OUTPUT(config_out_ready_o,1),

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
   .config_in_addr_i(config_in_addr_i),
   .config_in_valid_i(config_in_valid_i),
   .config_in_ready_o(config_in_ready_o),
   
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
   .config_out_addr_i(config_out_addr_i),
   .config_out_length_i(config_out_length_i),
   .config_out_valid_i(config_out_valid_i),
   .config_out_ready_o(config_out_ready_o),

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

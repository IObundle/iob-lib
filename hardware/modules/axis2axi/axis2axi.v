
module axis2axi
   #( 
      parameter AXI_ADDR_W = 0,
      parameter AXI_DATA_W = 32, // We currently only support 4 byte transfer
      parameter BURST_W = 0,
      parameter BURST_SIZE = 2**BURST_W,
      parameter BUFFER_W = BURST_W + 1,
      parameter BUFFER_SIZE = 2**BUFFER_W
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
   `include "m_axi_m_port.vh"

   `IOB_INPUT(clk_i,1),
   `IOB_INPUT(cke_i,1),
   `IOB_INPUT(rst_i,1)
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

   `include "m_axi_write_portmap.vh"
   
   .clk_i(clk_i),
   .cke_i(cke_i),
   .rst_i(rst_i)
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

   `include "m_axi_read_portmap.vh"
   
   .clk_i(clk_i),
   .cke_i(cke_i),
   .rst_i(rst_i)
   );

endmodule

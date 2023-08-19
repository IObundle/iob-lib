//Generate the RAM based on the parameters
generate
   if (W_DATA_W > R_DATA_W) begin : g_write_wider
      //memory write port
      assign ext_mem_w_en_o   = {R{w_en_int}};
      assign ext_mem_w_addr_o = w_addr;
      assign ext_mem_w_data_o = w_data_i;

      //register to hold the LSBs of r_addr
      wire [$clog2(R)-1:0] r_addr_lsbs_reg;
      iob_reg #(
         .DATA_W ($clog2(R)),
         .RST_VAL({$clog2(R) {1'd0}}),
         .CLKEDGE("posedge")
      ) r_addr_reg_inst (
         `include "clk_en_rst_s_s_portmap.vs"

         .data_i(r_addr[$clog2(R)-1:0]),
         .data_o(r_addr_lsbs_reg)
      );

      //memory read port
      assign ext_mem_r_en_o   = {{(R - 1) {1'd0}}, r_en_int} << r_addr[$clog2(R)-1:0];
      assign ext_mem_r_addr_o = r_addr[R_ADDR_W-1:$clog2(R)];

      wire [W_DATA_W-1:0] r_data;
      assign r_data   = ext_mem_r_data_i >> (r_addr_lsbs_reg * R_DATA_W);
      assign r_data_o = r_data[R_DATA_W-1:0];

   end else if (W_DATA_W < R_DATA_W) begin : g_read_wider
      //memory write port
      assign ext_mem_w_en_o = {{(R - 1) {1'd0}}, w_en_int} << w_addr[$clog2(R)-1:0];
      assign ext_mem_w_data_o = {{(R_DATA_W - W_DATA_W) {1'd0}}, w_data_i} << (w_addr[$clog2(
            R
      )-1:0] * W_DATA_W);
      assign ext_mem_w_addr_o = w_addr[W_ADDR_W-1:$clog2(R)];

      //memory read port
      assign ext_mem_r_en_o = {R{r_en_int}};
      assign ext_mem_r_addr_o = r_addr;
      assign r_data_o = ext_mem_r_data_i;

   end else begin : g_same_width
      //W_DATA_W == R_DATA_W
      //memory write port
      assign ext_mem_w_en_o   = w_en_int;
      assign ext_mem_w_addr_o = w_addr;
      assign ext_mem_w_data_o = w_data_i;

      //memory read port
      assign ext_mem_r_en_o   = r_en_int;
      assign ext_mem_r_addr_o = r_addr;
      assign r_data_o         = ext_mem_r_data_i;
   end
endgenerate

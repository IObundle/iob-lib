`timescale 1ns / 1ps

module iob_ram_2p_asym_wgtr
  #(
    parameter W_DATA_W = 0,
    parameter R_DATA_W = 0,
    parameter ADDR_W = 0, //higher ADDR_W (lower DATA_W)
    parameter R = W_DATA_W/R_DATA_W,
    parameter W_ADDR_W = ADDR_W-$clog2(R), //lower ADDR_W (higher DATA_W)
    parameter R_ADDR_W = ADDR_W
  )
  (
    input                 clk_i,

    //write port
    input                 w_en_i,
    input [W_ADDR_W-1:0]  w_addr_i, //lower ADDR_W (higher DATA_W)
    input [W_DATA_W-1:0]  w_data_i,
    //read port
    input                 r_en_i,
    input [R_ADDR_W-1:0]  r_addr_i, //higher ADDR_W (lower DATA_W)
    output [R_DATA_W-1:0] r_data_o,

    //write port
    output [R-1:0]        ext_mem_w_en_o,
    output [W_ADDR_W-1:0] ext_mem_w_addr_o,
    output [W_DATA_W-1:0] ext_mem_w_data_o,
    
    //read port
    output [R-1:0]        ext_mem_r_en_o,
    output [W_ADDR_W-1:0] ext_mem_r_addr_o,
    input [W_DATA_W-1:0]  ext_mem_r_data_i

    );

   //memory write port
  assign ext_mem_w_en_o = {R{w_en_i}};
  assign ext_mem_w_addr_o = w_addr_i;
  assign ext_mem_w_data_o = w_data_i;

   //register to hold the r_addr_i
  wire [R_ADDR_W-1:0] r_addr_reg;
  iob_reg_r #(
    .DATA_W(R_ADDR_W)
  ) r_addr_reg_inst (
    .clk_i(clk_i),
    .arst_i(1'b0),
    .cke_i(1'b1),
    .rst_i(1'b0),
    .data_i(r_addr_i),
    .data_o(r_addr_reg)
  );

   //memory read port
  wire [W_DATA_W-1:0]    r_data;
  generate
    if(R==1) begin
        assign ext_mem_r_en_o = r_en_i;
        assign r_data = ext_mem_r_data_i;
    end else begin
        assign ext_mem_r_en_o = r_en_i << r_addr_i[$clog2(R)-1:0];
        assign r_data = ext_mem_r_data_i >> (r_addr_reg[$clog2(R)-1:0]*R_DATA_W);
    end
  endgenerate
  
  assign ext_mem_r_addr_o = r_addr_i[R_ADDR_W-1:$clog2(R)];
  assign r_data_o = r_data[R_DATA_W-1:0];
      
endmodule

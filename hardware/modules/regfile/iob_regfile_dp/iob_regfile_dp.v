`timescale 1 ns / 1 ps
`include "iob_utils.vh"

/*
 * Register file implementing a CPU / User Logic interface
 */

module iob_regfile_dp 
  #(
    parameter N = 0,                //number of registers
    parameter W = 0,                //register width
    //cpu interface
    parameter MODE = "W",           //W: write only, R: read only, RW: read/write
    parameter ADDR_W  = 0,          //width of address
    parameter DATA_W  = 0,          //width of data
    parameter ADDR_OFFSET = 0      //byte offset of the address
) (
   input                           clk_i,
   input                           arst_i,
   input                           cke_i,

   //cpu interface
   input [(1+ADDR_W+1+DATA_W)-1:0] cpu_req_i, //avalid, addr, wen, wdata
   output [1+DATA_W:0]             cpu_resp_o, //ready, rvalid, rdata, 

   //logic interface
   input [($clog2(N)+1+W)-1:0]     logic_req_i, //addr, wen, wdata
   output [(2+W)-1:0]              logic_resp_o //ready, rdata
   
);

   //cpu interface
   wire                                  iob_avalid = cpu_req_i[1+ADDR_W+DATA_W];
   wire [ADDR_W-1:0]                     iob_addr = cpu_req_i[ADDR_W+DATA_W+(ADDR_W == 0)-:ADDR_W];
   wire [DATA_W-1:0]                     iob_wdata = cpu_req_i[DATA_W-1:0];
   wire                                  iob_wen = cpu_req_i[DATA_W];
   wire                                  iob_ready = 1'b1;
   wire                                  iob_rvalid;
   reg [DATA_W-1:0]                      iob_rdata;
   assign cpu_resp_o = {iob_ready, iob_rvalid, iob_rdata};
            
   //logic interface
   wire logic_wdata_i = logic_req_i[(W-1):0];
   wire logic_wen = logic_req_i[W];
   wire logic_addr = logic_req_i[W+1:$clog2(N)];
   
   //THE REGISTER FILE
   wire [N*W-1:0] regfile;
   reg [N*W-1:0]  regfile_wdata;
   reg [N-1:0]    regfile_wen;


   integer j;  
   genvar  i;

   generate 
      for (i=0; i < N; i=i+1) begin: g_regfile
                  iob_reg_e #(
                     .DATA_W (W),
                     .RST_VAL({W{1'b0}}),
                     .CLKEDGE("posedge")
                     ) iob_reg_inst (
                                     .clk_i (clk_i),
                                     .arst_i(arst_i),
                                     .cke_i (cke_i),
                                     .en_i  (regfile_wen[i]),
                                     .data_i(regfile_wdata[i*W+:W]),
                                     .data_o(regfile[i*W+:W])
                                     );
      end
   endgenerate

      
   generate 
      //extract CPU address if it exists
      if (ADDR_W > 0) begin: g_iob_addr
         //address exists: extract it 

         //generate write interface
         if (MODE != "R") begin: g_cpu_write_if
            if (W <= 8) begin: g_cpu_write_8
               always @* begin
                  regfile_wdata = regfile;
                  regfile_wen = {N{1'b0}};
                  for (j = 0; j < N; j=j+1) begin : g_cpu_write_word_loop
                     if ((iob_addr-ADDR_OFFSET) == j) begin
                        regfile_wdata[j*W+:W] = cpu_req_i[(8*(j%(DATA_W/8)))+:W];
                        regfile_wen[j] = cpu_req_i[DATA_W];
                     end
                  end
               end
            end else if (W <= 16) begin: g_cpu_write_16 // block: g_cpu_write_8
               always @* begin
                  regfile_wdata = regfile;
                  regfile_wen = {N{1'b0}};
                  for (j = 0; j < N; j=j+1) begin : g_cpu_write_word_loop
                     if ((iob_addr-ADDR_OFFSET) == j) begin
                        regfile_wdata[j*W+:W] = cpu_req_i[(16*(j%(DATA_W/16)))+:W];
                        regfile_wen[j] = cpu_req_i[DATA_W];
                     end
                  end
               end
            end else if (W <= 32) begin: g_cpu_write_32 // block: g_cpu_write_16
               always @* begin
                  regfile_wdata = regfile;
                  regfile_wen = {N{1'b0}};
                  for (j = 0; j < N; j=j+1) begin : g_cpu_write_word_loop
                     if ((iob_addr-ADDR_OFFSET) == j) begin
                        regfile_wdata[j*W+:W] = cpu_req_i[(32*(j%(DATA_W/32)))+:W];
                        regfile_wen[j] = cpu_req_i[DATA_W];
                     end
                  end
               end
            end else begin: g_cpu_write_64 // block: g_cpu_write_32
               always @* begin
                  regfile_wdata = regfile;
                  regfile_wen = {N{1'b0}};
                  for (j = 0; j < N; j=j+1) begin : g_cpu_write_word_loop
                     if ((iob_addr-ADDR_OFFSET) == j) begin
                        regfile_wdata[j*W+:W] = cpu_req_i[(64*(j%(DATA_W/64)))+:W];
                        regfile_wen[j] = cpu_req_i[DATA_W];
                     end
                  end
               end
            end // block: g_cpu_write_64
         end // block: g_cpu_write_if
      
         

         //generate read interface
         if (MODE != "W") begin : g_cpu_read_if
            //read interface exists: assemble data to read
            if (W <= 8) begin: g_cpu_read_8
               always @* begin
                  for (j = 0; j < N; j=j+1) begin
                     if (iob_addr == j) begin
                        iob_rdata[((8*j)%(DATA_W/8)+ADDR_OFFSET)%(DATA_W/8)+:8] = regfile[j*W+:W];
                     end
                  end
               end
            end else if (W <= 16) begin: g_cpu_read_16
               always @* begin
                  for (j = 0; j < N; j=j+2) begin
                     if (iob_addr == j) begin
                        iob_rdata[((16*j)%(DATA_W/8)+ADDR_OFFSET)%(DATA_W/8)+:16] = regfile[j*W+:W];
                     end
                  end
               end
            end else if (W <= 32) begin: g_cpu_read_32
               always @* begin
                  for (j = 0; j < N; j=j+4) begin
                     if (iob_addr == j) begin
                        iob_rdata[(32*j)%(DATA_W/8)+:32] = regfile[j*W+:W];
                     end
                  end
               end
            end else if (W <= 64) begin: g_cpu_read_64
               always @* begin
                  for (j = 0; j < N; j=j+8) begin
                     if (iob_addr == j) begin
                        iob_rdata[(64*j)%(DATA_W/8)+:64] = regfile[j*W+:W];
                     end
                  end
               end
            end

            //rvalid register
            wire iob_rvalid_nxt = iob_avalid & ~iob_wen;
            iob_reg #(
                      .DATA_W (1),
                      .RST_VAL({W{1'b0}}),
                      .CLKEDGE("posedge")
                      ) iob_reg_arvalid (
                                         .clk_i (clk_i),
                                         .arst_i(arst_i),
                                         .cke_i (cke_i),
                                         .data_i(iob_rvalid_nxt),
                                         .data_o(iob_rvalid)
                                         );

                        //assign read data

         end else begin : g_cpu_read_else // block: g_cpu_read_if
            assign iob_rvalid = 1'b0;
         end
         
      end // block: g_iob_addr
      
         

      if (MODE != "W") begin : g_logic_write_if
         assign logic_wen = 1'b0;
      end

   endgenerate
   
endmodule

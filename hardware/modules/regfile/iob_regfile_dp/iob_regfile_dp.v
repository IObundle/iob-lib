`timescale 1 ns / 1 ps
`include "iob_utils.vh"

module iob_regfile_dp 
  #(
    parameter N = 0,                //number of registers
    parameter W = 0,                //register width
    //cpu interface
    parameter CR = 0,                //can read
    parameter CW = 0,                //can write
    parameter CADDR_W  = 0,          //width of address
    parameter CRDATA_W  = 0,          //width of data
    parameter CWDATA_W  = 0,          //width of data
    parameter CWSTRB_W = DATA_W / 8  //width of write strobe
    //logic interface
    parameter LR = 0,                //can read
    parameter LW = 0,                //can write
    parameter LWDATA_W = 0,          //width of write data
    parameter LWADDR_W = 0,           //width of write address
    parameter LRDATA_W = 0,           //width of read data
    parameter LRADDR_W = 0           //width of read address
) (
   input                                     clk_i,
   input                                     arst_i,
   input                                     cke_i,

   //cpu interface
   input [(1+CADDR_W+CWSTRB_W+CWDATA_W)-1:0] cpu_req_i, //avalid, addr, wstrb, wdata
   output [(CRDATA_W+2)-1:0]                 cpu_resp_o, //rdata, ready, rvalid

   //logic interface
   input [(1+LADDR_W+LWDATA_W)-1:0]          logic_req_i, //valid, addr, wdata
   output [(1+LRDATA_W)-1:0]                 logic_resp_o //rdata, rvalid
   
);

   wire [(N*W)-1 : 0] regfile;
   wire [N-1:0] wen;
   wire cpu_wen;
   wire logic_wen;
   
   wire [(N*W)-1:0] wdata_int = logic_wen? logic_wdata : cpu_wdata;
   
   iob_reg_e #(
               .DATA_W (N*W),
               .RST_VAL({W{1'b0}}),
               .CLKEDGE("posedge")
               ) iob_reg_inst (
                               .clk_i (clk_i),
                               .arst_i(arst_i),
                               .cke_i (cke_i),
                               .en_i  (wen),
                               .data_i(wdata_int),
                               .data_o(regfile)
                               );
   
   generate 
      if (CWDATA_W != 0 || CRDATA_W != 0) begin : g_cpu_if
         //CPU interface exists
         if (CADDR_W != 0) begin: g_cpu_write_addr
            //address exists: extract it 
            wire cpu_addr_int = cpu_req_i[(CADDR_W+CWSTRB_W+CWDATA)-1-:CADDR_W];
         end

         //ready signal
         assign cpu_resp_o[(CDATA_W+1)-1] = 1'b1;
         
         //rvalid register
         wire arvalid = cpu_req_i[(1+CADDR_W+WSTRB_W+WDATA)-1];
         wire wstrb = cpu_req_i[(ADDR_W+WSTRB_W+WDATA)-1-:WSTRB_W];
         assign cpu_wen = arvalid & (wstrb != {WSTRB_W{1'b0}});
         
         iob_reg #(
                   .DATA_W (1),
                   .RST_VAL({W{1'b0}}),
                   .CLKEDGE("posedge")
                   ) iob_reg_arvalid (
                               .clk_i (clk_i),
                               .arst_i(arst_i),
                               .cke_i (cke_i),
                               .en_i  (cpu_wen),
                               .data_i(wdata_int),
                               .data_o(regfile)
                               );
   
         if (WDATA_W != 0) begin : g_cpu_write_if
            //write interface exists: extract data to write
            wire [N-1:0] cpu_wen;
            wire [(N*W)-1:0] cpu_wdata_int;
            for (i = 0; i < N*W; i=i+1) begin : g_cpu_write_word_loop
               if (i >= cpu_addr_int  && (i+1) < cpu_addr_int ) begin : g_cpu_write_word_if
                  assign cpu_wdata_int[i*W+:W] = cpu_req_i[(i%WSTRB_W)+:W];
                  assign cpu_wen[i] = 1'b1;
               end else begin : g_cpu_write_word_else
                  assign cpu_wdata[i*W] = {W{1'b0}};
                  assign cpu_wen[i] = 1'b0;
               end
            end
         end

         if (RDATA_W != 0) begin : g_cpu_read_if
            //read interface exists: assemble data to read
            wire [N-1:0] cpu_rdata_int;
            for (i = 0; i < N; i=i+1) begin : g_cpu_read_word_loop
               if (i >= cpu_addr_int  && (i+1) < cpu_addr_int ) begin : g_cpu_read_word_if
                  assign cpu_rdata_int[(i%WSTRB_W)*W+:W] = regfile[i*W+:W];
               end else begin : g_cpu_read_word_else
                  assign cpu_rdata_int[i*W] = {W{1'b0}};
               end
            end
            cpu_resp_o[2+:WDATA] = {cpu_rdata_int, 1'b1, 1'b1};
         end
      end else begin : g_cpu_no_if
         //CPU interface does not exist
         assign cpu_wen = 1'b0;
         assign cpu_resp_o = {CRDATA_W{1'b0}, 1'b1, 1'b1};
      end
   endgenerate


   genvar           i;
   genvar           j;
     wire [N-1:0] addr_int;

     //extract data to write

       //write enable
     if(WORD_TYPE) begin
        assign wen = 

   //read register file
   generate
      if (RADDR_W > 0) begin : g_read
         wire [RADDR_W-1:0] raddr = req_i[(WSTRB_W+WDATA_W)+WADDR_W+:RADDR_W];
         assign resp_o = regfile[RDATA_W*raddr+:RDATA_W];
      end else begin : g_read
         assign resp_o = regfile;
      end
   endgenerate

endmodule

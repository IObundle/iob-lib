`timescale 1 ns / 1 ps
`include "iob_utils.vh"

/*
 * Register file implementing a CPU / User Logic interface for 32-bit architecture
 */

module iob_regfile_dp 
  #(
    parameter N = 2,               //number of registers
    parameter W = 1,               //register width
    parameter MODE = "RW",         //register mode: RW, RO, WO
    //cpu interface
    parameter ADDR_W  = 0,         //address width
    parameter DATA_W  = 0,         //data width
    parameter ADDR_OFFSET = 0,     //address byte offset
    //logic interface
    parameter LADDR_W = $clog2(N)  //address width for load
) (
   input                                  clk_i,
   input                                  arst_i,
   input                                  cke_i,

   //cpu interface
   input [1+ADDR_W+DATA_W+(DATA_W/8)-1:0] req_i, //avalid, address, wstrb, wdata
   output reg [1+DATA_W-1:0]              rsp_o, //ack, rdata

   //user logic interface
   input [(1+LADDR_W+1+W)-1:0]            lreq_i, //avalid, address, wstrb, wdata
   output reg [(1+W)-1:0]                 lrsp_o //ack, rdata
);

   ////////////////////////////////////////////////////////////////////////////////   
   //THE REGISTER FILE
   //
   wire [N*W+ADDR_OFFSET-1:ADDR_OFFSET] regfile;
   reg [N*W+ADDR_OFFSET-1:+ADDR_OFFSET] regfile_wdata;
   wire [(N*W)-1:0]                     regfile_wen;
   
   wire [(N*W)-1:0]                     cpu_wen;
   wire [(N*W)-1:0]                     cpu_wdata;

   wire [(N*W)-1:0]                     logic_wen;
   wire [(N*W)-1:0]                     logic_wdata;
   
   
   genvar                               i, j;

   generate
      for (i=0; i < N*W; i=i+1) begin: g_regfile_loop
         iob_reg_e #(
                     .DATA_W (1),
                     .RST_VAL({1'b0}),
                     .CLKEDGE("posedge")
                     ) iob_reg_inst (
                                     .clk_i (clk_i),
                                     .arst_i(arst_i),
                                     .cke_i (cke_i),
                                     .en_i  (regfile_wen[i+ADDR_OFFSET]),
                                     .data_i(regfile_wdata[i+ADDR_OFFSET]),
                                     .data_o(regfile[i+ADDR_OFFSET])
                                     );
      end
   endgenerate

   //regfile write logic
   generate
      if (MODE == "RO") begin: g_write_ro
         assign regfile_wen = logic_wen;
         assign regfile_wdata = logic_wdata;
      end else if (MODE == "WO") begin: g_write_wo
         assign regfile_wen = cpu_wen;
         assign regfile_wdata = cpu_wdata;
      end  else begin: g_write_rw
         assign regfile_wen = cpu_wen | logic_wen;
         assign regfile_wdata = cpu_wen ? cpu_wdata : logic_wdata;
      end
   endgenerate



   /////////////////////////////////////////////////////////////////
   //CPU INTERFACE: AVALID, ADDR, WDATA, WSTRB | ACK, RDATA
   //
   
   //extract avalid
   wire avalid;
   generate
      if (MODE == "RO") begin: g_avalid_ro //cpu can write
         assign avalid = req_i[1+ADDR_W-1];
      end else begin: g_avalid_w //cpu can't write
         assign avalid = req_i[1+ADDR_W+DATA_W+(DATA_W/8)-1];
      end
   endgenerate
   
   //extract address
   generate
      if (ADDR_W > ($clog2(DATA_W/8))) begin: g_addr
         wire [ADDR_W-1:0]             addr = req_i[ADDR_W+DATA_W+(DATA_W/8)-1-:ADDR_W];
      end
   endgenerate

   //extract wstrb and wdata
   generate
      if (MODE != "RO") begin: g_write //cpu can write
         wire [DATA_W-1:0]             wstrb = req_i[DATA_W+(DATA_W/8)-1-:(DATA_W/8)];
         wire [DATA_W/8-1:0]           wdata = req_i[DATA_W-1:0];
      end
   endgenerate

   //construct ack and rdata
   //ack
   wire                                ack;
   //rdata   
   generate 
      if (MODE == "WO") begin: g_rdata_wo
         assign rsp_o = ack;
      end else begin: g_rdata_r
         wire [DATA_W-1:0]             rdata;
         assign rsp_o = {ack, rdata};
      end
   endgenerate

   /////////////////////////////////////////////////////////////////
   //LOGIC INTERFACE: AVALID, ADDR, WDATA, WSTRB | ACK, RDATA

   //extract avalid
   wire l_avalid;
   generate
      if(MODE == "WO") begin: g_lavalid_wo //the logic can't write
         assign                         l_avalid = lreq_i[1+LADDR_W-1];
      end else begin: g_lavalid_r //the logic can write
         assign                           l_avalid = lreq_i[1+LADDR_W+W+1-1];
      end
   endgenerate

   //extract address
   generate
      wire [LADDR_W-1:0]            l_addr = lreq_i[1+LADDR_W+W+1-1-:LADDR_W];
      if (LADDR_W > 0) begin: g_laddr
         if(MODE == "WO") begin: g_laddr_wo //the logic can't write
            wire [LADDR_W-1:0]            l_addr = lreq_i[1+LADDR_W-1-:LADDR_W];
         end else begin: g_laddr_r //the logic can write
            wire [LADDR_W-1:0]            l_addr = lreq_i[1+LADDR_W+W+1-1-:LADDR_W];
         end
      end
   endgenerate

   //extract wstrb and wdata
   generate
      wire             l_wstrb = lreq_i[(W+1)-1-:W];
      wire [W-1:0]     l_wdata = lreq_i[W-1:0];
      if (MODE != "WO") begin: g_l_write //logic can write
         wire             l_wstrb = lreq_i[(W+1)-1-:W];
         wire [W-1:0]     l_wdata = lreq_i[W-1:0];
      end
   endgenerate


   
   //construct ack and rdata; the logic can always read
   //lack
   wire                                   l_ack;
   wire [W-1:0]                           l_rdata;
   assign lrsp_o = {l_ack, l_rdata};

   
   //CPU reads
   localparam NBYTES_PER_ITEM = (W <= 8)? 1: (W <= 16)? 2: (W <= 32)? 4: 8;
      
   generate
      if (MODE != "WO") begin : g_cpu_reads
         wire [DATA_W-1:0]                     rdata;
         for (i=0; i<(DATA_W/8); i=i+NBYTES_PER_ITEM) begin: g_bytes_loop
            for (j=0; j<NBYTES_PER_ITEM; j=j+1) begin:  g_nbytes_loop
               if ((i+j)>=ADDR_OFFSET && (i+j) < (ADDR_OFFSET+N)) begin: g_rdata_if
                  if (ADDR_W <= (DATA_W/8)) begin: g_rdata_no_addr
                     assign rdata[i*8+:8] = regfile[(i*W)+:W];
                  end else begin: g_rdata_addr
                     assign rdata[addr*(DATA_W/8)+i*8+:8] = regfile[(addr*(DATA_W/8)+i*W)+:W];
                  end
               end else begin: g_rdata_else
                  if (ADDR_W <= (DATA_W/8)) begin: g_rdata_no_addr
                     assign rdata[i*8+:8] = 8'd0;
                  end else begin: g_rdata_addr                     
                     assign rdata[addr*(DATA_W/8)+i*8+:8] = regfile[(addr*(DATA_W/8)+i*W)+:W];
                  end
               end
            end
         end
      end
   endgenerate
         
     
   //CPU writes
   generate
      if (MODE != "RO") begin : g_cpu_writes
         wire [DATA_W-1:0]                     wdata;
         wire [DATA_W/8-1:0]                   wstrb;
         for (i=0; i<(DATA_W/8); i=i+NBYTES_PER_ITEM) begin: g_bytes_loop
            for (j=0; j<NBYTES_PER_ITEM; j=j+1) begin:  g_nbytes_loop
               if ((i+j)>=ADDR_OFFSET && (i+j) < (ADDR_OFFSET+N)) begin: g_wdata_if
                  if (ADDR_W <= (DATA_W/8)) begin: g_wdata_no_addr
                     assign cpu_wdata[i*8+:8] = wdata[i*8+:8];
                     assign cpu_wen[i] = wstrb[i];
                  end else begin: g_wdata_addr
                     assign cpu_wdata[addr*(DATA_W/8)+i*8+:8] = wdata[i*8+:8];
                     assign cpu_wen[addr*(DATA_W/8)+i] = wstrb[i];
                  end
               end else begin: g_wdata_else
                  if (ADDR_W <= (DATA_W/8)) begin: g_wdata_no_addr
                     assign cpu_wdata[i*8+:8] = 8'd0;
                     assign cpu_wen[i] = 1'b0;
                  end else begin: g_wdata_addr
                     assign cpu_wdata[addr*(DATA_W/8)+i*8+:8] = 8'd0;
                     assign cpu_wen[addr*(DATA_W/8)+i] = 1'b0;
                  end
               end
            end
         end
      end
   endgenerate

   //logic reads (can always read)
   generate
      if (LADDR_W > 0) begin: g_has_addr
         assign l_rdata = regfile[l_addr*W+:W];
      end else begin: g_no_addr
         assign l_rdata = regfile;
      end
   endgenerate

   //logic writes
   generate
      if (MODE != "WO") begin : g_logic_writes
         if (LADDR_W > 0) begin: g_has_addr
            assign logic_wen = {{(N-1)*W{1'b0}}, {W{l_wstrb}}} << l_addr;
         end else begin: g_no_addr
            assign logic_wen = {N*W{l_wstrb}};
         end
      end
   endgenerate


   //CPU ack register
   iob_reg #(
               .DATA_W (1),
               .RST_VAL(1'b0),
               .CLKEDGE("posedge")
               ) iob_reg_ack (
                               .clk_i (clk_i),
                               .arst_i(arst_i),
                               .cke_i (cke_i),
                               .data_i(avalid),
                               .data_o(ack)
                               );

   //LOGIC ack register
   iob_reg #(
               .DATA_W (1),
               .RST_VAL(1'b0),
               .CLKEDGE("posedge")
               ) iob_reg_l_ack (
                               .clk_i (clk_i),
                               .arst_i(arst_i),
                               .cke_i (cke_i),
                               .data_i(l_avalid),
                               .data_o(l_ack)
                               );
   
endmodule

`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_regfile_dp_tb;

   localparam DATA_W = 32;

              
   localparam MODE = "RW";   
   localparam N = 8;
   localparam W = 8;
   localparam NBYTES = (W<=8) ? N : (W<=16) ? 2*N : 4*N;
   localparam ADDR_W = $clog2(NBYTES);
   localparam LADDR_W = $clog2(N);
   
   reg                 arst;
   reg                 cke;


   //cpu interface   
   reg                 iob_avalid_i;
   reg [ADDR_W-1:0]    iob_addr_i;
   reg [DATA_W-1:0]    iob_wdata_i;
   reg [DATA_W/8-1:0]  iob_wstrb_i;
   wire [DATA_W-1:0]   iob_rdata_o;
   wire                iob_ack_o;

   //logic block interface
   reg [LADDR_W-1:0]   logic_addr_i;
   reg [W-1:0]         logic_wdata_i;
   reg                 logic_we_i;
   wire [W-1:0]        logic_rdata_o;
   wire                logic_ack_o;

   reg [DATA_W-1:0]    rdata;
   
   // clock
   `IOB_CLOCK(clk, 10)

   integer             i;
   
   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      $display("Starting testbench");
      $display("MODE = %s", MODE);
      
      cke = 1;
      iob_avalid_i = 0;
      iob_wstrb_i = 0;
      
      logic_we_i = 0;

      // pulse reset
      `IOB_PULSE(arst, 11, 12, 13)

      for (i=0; i<N; i=i+1) begin
         iob_write(i, ~i, W);
      end

      for (i=0; i<N; i=i+1) begin
         iob_read(i, rdata, W);
         if (rdata[(i%(DATA_W/8))*8+:W] !== ~i[W-1:0]) begin
            $display("rdata = %h", rdata);
            $display("ERROR: rdata = %h, expected %h", rdata[(i%(DATA_W/8))*8+:W], ~i[W-1:0]);
            $display("%h", uut.regfile);
            //$fatal(1);
         end
      end


      #100 $finish();
      
   end

   wire [1+ADDR_W+DATA_W+(DATA_W/8)-1:0] cpu_req_i = {iob_avalid_i, iob_addr_i, iob_wstrb_i, iob_wdata_i};
   wire [(1+DATA_W)-1:0]                 cpu_resp_o;
   
   wire [(1+LADDR_W+1+W)-1:0]            logic_req_i = {logic_addr_i, logic_we_i, logic_wdata_i};
   wire [(1+W)-1:0]                      logic_resp_o;
   
   assign iob_ack_o = cpu_resp_o[DATA_W];
   assign iob_rdata_o = cpu_resp_o[DATA_W-1:0];
    
   iob_regfile_dp #(
                    .N(N),
                    .W(W),
                    .MODE(MODE),
                    .DATA_W(DATA_W),
                    .ADDR_W(ADDR_W),
                    .ADDR_OFFSET(0)
                    ) uut (
                           .clk_i(clk),
                           .arst_i(arst),
                           .cke_i(cke),
                           .req_i(cpu_req_i),
                           .rsp_o(cpu_resp_o),
                           .lreq_i(logic_req_i),
                           .lrsp_o(logic_resp_o)
                           );

   // Write data to IOb Native slave
   task iob_write;
      input [ADDR_W-1:0] addr;
      input [DATA_W-1:0] data;
      input [$clog2(DATA_W):0] width;
      
      begin
         @(posedge clk) #1 iob_avalid_i = 1;  //sync and assign
         iob_addr_i  = addr;
         iob_wdata_i = `IOB_GET_WDATA(addr, data);
         iob_wstrb_i = `IOB_GET_WSTRB(addr, width);         
         @(posedge clk) iob_avalid_i = 0;
         iob_wstrb_i = 0;
      end
   endtask

   // Read data from IOb Native slave
   task iob_read;
      input [ADDR_W-1:0] addr;
      output [DATA_W-1:0] data;
      input [$clog2(DATA_W):0] width;
      
      begin
         @(posedge clk) #1 iob_avalid_i = 1;
         iob_addr_i = addr;         
         @(posedge clk) #1 iob_avalid_i = 0;
         while (!iob_ack_o) #1;
         data = #1 `IOB_GET_RDATA(addr, iob_rdata_o, width);
  end
endtask


endmodule

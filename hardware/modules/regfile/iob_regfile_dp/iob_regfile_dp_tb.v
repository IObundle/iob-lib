`timescale 1ns / 1ps
`include "iob_utils.vh"

module iob_regfile_dp_tb;

   localparam DATA_W = 32;

   localparam N = 8;
   localparam W = 8;
              
   localparam MODE = "RW";


   localparam NBYTES = (W<=8) ? N : (W<=16) ? 2*N : 4*N;
   localparam ADDR_W = $clog2(NBYTES);

   
   reg                 arst;
   reg                 cke;


   //cpu interface   
   reg                 iob_avalid_i;
   reg [ADDR_W-1:0]    iob_addr_i;
   reg [DATA_W-1:0]    iob_wdata_i;
   reg [DATA_W/8-1:0]  iob_wstrb_i;
   wire [DATA_W-1:0]   iob_rdata_o;
   wire                iob_ready_o;
   wire                iob_rvalid_o;

   //logic block interface
   reg [$clog2(N)-1:0] logic_addr_i;
   reg [W-1:0]         logic_wdata_i;
   reg                 logic_we_i;
   wire [W-1:0]        logic_rdata_o;
   wire                logic_ready_o;

   reg [DATA_W-1:0]    rdata;
   
   // clock
   `IOB_CLOCK(clk, 10)
  
   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      cke = 1;
      iob_avalid_i = 0;
      iob_wstrb_i = 0;
      
      logic_we_i = 0;

      // pulse reset
      `IOB_PULSE(arst, 11, 12, 13)
      
      iob_write(0, 1, W);
      iob_read(0, rdata, W);

      #100 $finish();
      
   end

   wire [(1+ADDR_W+1+DATA_W)-1:0] cpu_req_i = {iob_avalid_i, iob_addr_i, |iob_wstrb_i, iob_wdata_i};
   wire [(2+DATA_W)-1:0]               cpu_resp_o;
   
   wire [($clog2(N)+1+W)-1:0]          logic_req_i = {logic_addr_i, logic_we_i, logic_wdata_i};
   wire [(2+W)-1:0]                    logic_resp_o;
   
   assign iob_ready_o = cpu_resp_o[1+DATA_W];
   assign iob_rvalid_o = cpu_resp_o[DATA_W];
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
                           .cpu_req_i(cpu_req_i),
                           .cpu_resp_o(cpu_resp_o),
                           .logic_req_i(logic_req_i),
                           .logic_resp_o(logic_resp_o)
                           );

   `include "iob_tasks.vh"

endmodule

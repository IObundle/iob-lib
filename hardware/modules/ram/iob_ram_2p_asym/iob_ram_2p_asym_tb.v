`timescale 1ns / 1ps
`include "iob_lib.vh"

// test defines
`define MAXADDR_W 10

module iob_ram_2p_asym_tb;

   // determine W_ADDR_W and R_ADDR_W
   localparam W_DATA_W = `W_DATA_W;
   localparam R_DATA_W = `R_DATA_W;
   localparam MAXDATA_W = `IOB_MAX(W_DATA_W, R_DATA_W);
   localparam MINDATA_W = `IOB_MIN(W_DATA_W, R_DATA_W);
   localparam MAXADDR_W = `MAXADDR_W;
   localparam MINADDR_W = MAXADDR_W - $clog2(MAXDATA_W/MINDATA_W);
   localparam W_ADDR_W = W_DATA_W == MINDATA_W? MAXADDR_W: MINADDR_W;
   localparam R_ADDR_W = R_DATA_W == MINDATA_W? MAXADDR_W: MINADDR_W;
   localparam R = MAXDATA_W/MINDATA_W;

   // system clock
   `IOB_CLOCK(clk, 10)
   
   // write port
   reg w_en = 0;
   reg [W_DATA_W-1:0] w_data;
   reg [W_ADDR_W-1:0] w_addr;

   // read port
   reg                r_en = 0;
   reg [R_ADDR_W-1:0]  r_addr;
   wire [R_DATA_W-1:0] r_data;



   // external memory 
   // write port
   wire ext_mem_clk;
   wire [R-1:0] ext_mem_w_en;
   wire [MINADDR_W-1:0] ext_mem_w_addr;
   wire [MAXDATA_W-1:0] ext_mem_w_data;
   // read port
   wire [R-1:0]         ext_mem_r_en;
   wire [MINADDR_W-1:0] ext_mem_r_addr;
   wire [MAXDATA_W-1:0] ext_mem_r_data;


   localparam seq_ini = 10;
   integer             i;

   reg [W_DATA_W*2**W_ADDR_W-1:0] test_data;
   reg [R_DATA_W-1:0]             r_data_expected;

   initial begin

`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      $display("W_DATA_W=%d", W_DATA_W);
      $display("W_ADDR_W=%d", W_ADDR_W);
      $display("R_DATA_W=%d", R_DATA_W);
      $display("R_ADDR_W=%d", R_ADDR_W);

      if(W_DATA_W > R_DATA_W)
        $display("W_DATA_W > R_DATA_W");
      else if (W_DATA_W < R_DATA_W)
        $display("W_DATA_W < R_DATA_W");
      else
        $display("W_DATA_W = R_DATA_W");

      // compute the test_data
      for (i=0; i < 2**W_ADDR_W; i=i+1)
        test_data[i*W_DATA_W +: W_DATA_W] = i+seq_ini;

      //wait 4 cycles
      repeat(4) @(posedge clk) #1;

      // write all the locations of RAM
      w_en = 1;
      for(i = 0; i < 2**W_ADDR_W; i = i + 1) begin
         w_addr = i;         
         w_data = i+seq_ini;

         @(posedge clk) #1;
      end
      w_en = 0;
      @(posedge clk) #1;

      // read all the locations of RAM
      r_en = 1;
      for(i = 0 ; i < 2**R_ADDR_W; i = i + 1) begin
         r_addr = i;
         @(posedge clk) #1;
         // verify response
         r_data_expected = test_data[i*R_DATA_W +: R_DATA_W];
         if(r_data !== r_data_expected) begin
            $display("Read addr=%x, got %x, expected %x", r_addr, r_data, r_data_expected);
            $fatal(1, "Test failed");
         end
      end

      //wait 5 cycles and finish
      repeat(5) @(posedge clk) #1;
      $finish;
   end

   // instantiate the Unit Under Test (UUT)
   iob_ram_2p_asym #(
      .W_DATA_W(W_DATA_W),
      .R_DATA_W(R_DATA_W),
      .ADDR_W(MAXADDR_W)
   ) uut (
      .clk_i            (clk),
      .arst_i           (1'd0),
      .cke_i            (1'd1),

      .ext_mem_clk_o    (ext_mem_clk),
      .ext_mem_w_en_o   (ext_mem_w_en),
      .ext_mem_w_data_o (ext_mem_w_data),
      .ext_mem_w_addr_o (ext_mem_w_addr),
      .ext_mem_r_en_o   (ext_mem_r_en),
      .ext_mem_r_addr_o (ext_mem_r_addr),
      .ext_mem_r_data_i (ext_mem_r_data),

      .w_en_i           (w_en),
      .w_addr_i         (w_addr),
      .w_data_i         (w_data),

      .r_en_i           (r_en),
      .r_addr_i         (r_addr),
      .r_data_o         (r_data)
   );

   genvar p;
   generate 
      for(p = 0;p < R; p = p + 1) begin
         iob_ram_2p #(
            .DATA_W(MINDATA_W),
            .ADDR_W(MINADDR_W)
         ) iob_ram_2p_inst (
            .clk_i(ext_mem_clk),
            .w_en_i(ext_mem_w_en[p]),
            .w_addr_i(ext_mem_w_addr),
            .w_data_i(ext_mem_w_data[p*MINDATA_W +: MINDATA_W]),
            .r_en_i(ext_mem_r_en[p]),
            .r_addr_i(ext_mem_r_addr),
            .r_data_o(ext_mem_r_data[p*MINDATA_W +: MINDATA_W])
         );
      end
   endgenerate

endmodule
